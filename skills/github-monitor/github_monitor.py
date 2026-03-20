#!/usr/bin/env python3
"""
GitHub Monitor v2 — OpenClaw Skill Plugin
搜尋、追蹤、分類 GitHub 上的熱門與快速增長專案。
支援趨勢分析、用戶興趣匹配、歷史快照比對。
"""

import argparse
import json
import os
import sys
import time
import urllib.request
import urllib.parse
import urllib.error
from datetime import datetime, timezone, timedelta
from pathlib import Path

# ─── Paths ────────────────────────────────────────────────
SKILL_DIR = Path(__file__).parent
CACHE_DIR = SKILL_DIR / "cache"
SNAPSHOTS_DIR = SKILL_DIR / "snapshots"
PLUGIN_CONFIG = SKILL_DIR.parent / "plugin_list.json"

# ─── User Interest Categories ─────────────────────────────
# 根據用戶 profile 定義的興趣領域與關鍵字
CATEGORIES = {
    "ai-agent": {
        "label": "AI Agent / LLM 工具",
        "keywords": ["ai-agent", "llm", "agent", "autonomous", "tool-use", "function-calling",
                      "chatbot", "assistant", "copilot", "agentic"],
        "queries": ["ai agent framework", "llm agent tool"],
    },
    "mcp-server": {
        "label": "MCP Server / Claude 生態系",
        "keywords": ["mcp", "mcp-server", "model-context-protocol", "claude", "anthropic",
                      "claude-code", "claude-skill", "openclaw"],
        "queries": ["model context protocol server", "claude mcp"],
    },
    "robotics": {
        "label": "機器人 / ROS 2 / SLAM / Navigation",
        "keywords": ["ros2", "ros", "slam", "navigation", "robotics", "robot", "lidar",
                      "gazebo", "nav2", "moveit", "urdf", "sensor-fusion"],
        "queries": ["ros2 slam navigation", "robotics framework python"],
    },
    "rl-sim": {
        "label": "強化學習 / 模擬器 (Isaac Sim)",
        "keywords": ["reinforcement-learning", "rl", "isaac-sim", "isaaclab", "rsl-rl",
                      "gym", "gymnasium", "mujoco", "pybullet", "omniverse", "sim-to-real"],
        "queries": ["reinforcement learning robotics", "isaac sim gym environment"],
    },
    "3d-pointcloud": {
        "label": "點雲 / 3D 感測 / 電腦視覺",
        "keywords": ["point-cloud", "pointcloud", "open3d", "pcl", "3d-reconstruction",
                      "depth-estimation", "nerf", "gaussian-splatting", "3d-vision", "lidar"],
        "queries": ["point cloud processing python", "3d reconstruction deep learning"],
    },
    "flutter-mobile": {
        "label": "Flutter / 行動應用開發",
        "keywords": ["flutter", "dart", "android", "ios", "mobile", "cross-platform",
                      "riverpod", "bloc", "firebase"],
        "queries": ["flutter app template", "flutter ai integration"],
    },
    "quant-trading": {
        "label": "量化交易 / 金融科技",
        "keywords": ["quantitative-trading", "quant", "algorithmic-trading", "backtest",
                      "trading-bot", "crypto-trading", "fintech", "portfolio", "ta-lib"],
        "queries": ["quantitative trading python", "algorithmic trading framework"],
    },
    "devops-infra": {
        "label": "DevOps / 基礎設施 / Docker",
        "keywords": ["docker", "docker-compose", "kubernetes", "ci-cd", "devops",
                      "terraform", "ansible", "self-hosted", "homelab"],
        "queries": ["self-hosted ai infrastructure", "docker ai deployment"],
    },
}

# ─── Tracked Repos ────────────────────────────────────────
TRACKED_REPOS = [
    "modelcontextprotocol/servers",
    "browser-use/browser-use",
    "pydantic/pydantic-ai",
    "anthropics/claude-code",
    "NVIDIA-Omniverse/IsaacGymEnvs",
    "leggedrobotics/rsl_rl",
    "ros2/ros2",
    "open3d-ml/Open3D-ML",
]

HEADERS = {
    "Accept": "application/vnd.github.v3+json",
    "User-Agent": "OpenClaw-GitHub-Monitor/2.0",
}


# ─── GitHub API ───────────────────────────────────────────

def get_headers():
    h = dict(HEADERS)
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        h["Authorization"] = f"token {token}"
    return h


def api_get(url: str) -> dict | list:
    req = urllib.request.Request(url, headers=get_headers())
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        if e.code == 403:
            return {"error": "rate_limited", "message": "GitHub API rate limit. Set GITHUB_TOKEN."}
        if e.code == 404:
            return {"error": "not_found", "message": f"Not found: {url}"}
        return {"error": f"http_{e.code}", "message": str(e)}
    except Exception as e:
        return {"error": "request_failed", "message": str(e)}


def search_repos(query: str, sort: str = "stars", per_page: int = 20) -> list:
    q = urllib.parse.quote(query)
    url = f"https://api.github.com/search/repositories?q={q}&sort={sort}&order=desc&per_page={per_page}"
    data = api_get(url)
    if isinstance(data, dict) and "error" in data:
        return [data]
    return [extract_repo_info(r) for r in data.get("items", [])]


def search_recent_trending(query: str, days: int = 7, per_page: int = 15) -> list:
    """Search repos created or pushed within recent days, sorted by stars."""
    since = (datetime.now(timezone.utc) - timedelta(days=days)).strftime("%Y-%m-%d")
    full_query = f"{query} pushed:>{since}"
    return search_repos(full_query, sort="stars", per_page=per_page)


def get_repo_info(owner_repo: str) -> dict:
    url = f"https://api.github.com/repos/{owner_repo}"
    data = api_get(url)
    if isinstance(data, dict) and "error" in data:
        return data
    info = extract_repo_info(data)
    # Recent commits
    commits_url = f"https://api.github.com/repos/{owner_repo}/commits?per_page=5"
    commits = api_get(commits_url)
    if isinstance(commits, list):
        info["recent_commits"] = len(commits)
        if commits:
            info["last_commit_date"] = commits[0].get("commit", {}).get("committer", {}).get("date", "")
    return info


def extract_repo_info(repo: dict) -> dict:
    now = datetime.now(timezone.utc)
    pushed = repo.get("pushed_at", "")
    created = repo.get("created_at", "")
    days_since_push = None
    days_since_create = None
    if pushed:
        try:
            days_since_push = (now - datetime.fromisoformat(pushed.replace("Z", "+00:00"))).days
        except (ValueError, TypeError):
            pass
    if created:
        try:
            days_since_create = (now - datetime.fromisoformat(created.replace("Z", "+00:00"))).days
        except (ValueError, TypeError):
            pass

    return {
        "full_name": repo.get("full_name", ""),
        "description": repo.get("description", ""),
        "stars": repo.get("stargazers_count", 0),
        "forks": repo.get("forks_count", 0),
        "open_issues": repo.get("open_issues_count", 0),
        "language": repo.get("language", ""),
        "topics": repo.get("topics", []),
        "created_at": created,
        "updated_at": repo.get("updated_at", ""),
        "pushed_at": pushed,
        "days_since_push": days_since_push,
        "days_since_create": days_since_create,
        "license": (repo.get("license") or {}).get("spdx_id", ""),
        "url": repo.get("html_url", ""),
        "archived": repo.get("archived", False),
        "default_branch": repo.get("default_branch", "main"),
    }


# ─── Classification ──────────────────────────────────────

def classify_repo(repo: dict) -> list:
    """Classify a repo into user interest categories. Returns list of (category_id, confidence)."""
    text = " ".join([
        (repo.get("full_name") or ""),
        (repo.get("description") or ""),
        " ".join(repo.get("topics", [])),
    ]).lower()

    matches = []
    for cat_id, cat in CATEGORIES.items():
        score = 0
        for kw in cat["keywords"]:
            if kw in text:
                score += 1
        if score > 0:
            confidence = min(score / 3.0, 1.0)
            matches.append((cat_id, round(confidence, 2)))

    matches.sort(key=lambda x: x[1], reverse=True)
    return matches[:3] if matches else [("uncategorized", 0.0)]


def score_compatibility(repo: dict) -> dict:
    score = 0
    reasons = []

    lang = (repo.get("language") or "").lower()
    if lang in ("python", "typescript", "javascript", "dart"):
        score += 25
        reasons.append(f"lang:{lang}")
    elif lang in ("c++", "rust", "go"):
        score += 15
        reasons.append(f"lang:{lang}")
    elif lang:
        score += 5

    topics = [t.lower() for t in repo.get("topics", [])]
    all_keywords = set()
    for cat in CATEGORIES.values():
        all_keywords.update(cat["keywords"])
    matched = set(topics) & all_keywords
    score += min(len(matched) * 8, 30)
    if matched:
        reasons.append(f"topics:{','.join(list(matched)[:5])}")

    days = repo.get("days_since_push")
    if days is not None:
        if days <= 3:
            score += 20
            reasons.append("hot")
        elif days <= 14:
            score += 15
            reasons.append("active")
        elif days <= 60:
            score += 5
            reasons.append("moderate")
        else:
            reasons.append("stale")

    stars = repo.get("stars", 0)
    if stars >= 10000:
        score += 20
        reasons.append("mega_popular")
    elif stars >= 1000:
        score += 15
        reasons.append("popular")
    elif stars >= 100:
        score += 10
        reasons.append("growing")
    elif stars >= 10:
        score += 5

    if repo.get("archived"):
        score -= 30
        reasons.append("archived")

    return {"score": max(0, min(score, 100)), "reasons": reasons}


def score_user_relevance(repo: dict) -> dict:
    """Score how relevant this repo is to the user's specific interests."""
    categories = classify_repo(repo)
    compat = score_compatibility(repo)

    # Boost score for user's primary interests
    primary_interests = {"ai-agent", "mcp-server", "robotics", "rl-sim", "quant-trading"}
    interest_boost = 0
    for cat_id, conf in categories:
        if cat_id in primary_interests:
            interest_boost += int(conf * 20)

    total = min(compat["score"] + interest_boost, 100)
    return {
        "total_score": total,
        "compat_score": compat["score"],
        "interest_boost": interest_boost,
        "categories": categories,
        "reasons": compat["reasons"],
    }


# ─── Snapshots & Growth ──────────────────────────────────

def save_snapshot(repos: list):
    """Save today's star counts for growth comparison."""
    SNAPSHOTS_DIR.mkdir(parents=True, exist_ok=True)
    today = datetime.now().strftime("%Y%m%d")
    snapshot = {}
    for r in repos:
        if "error" not in r and r.get("full_name"):
            snapshot[r["full_name"]] = {
                "stars": r.get("stars", 0),
                "forks": r.get("forks", 0),
            }
    path = SNAPSHOTS_DIR / f"snapshot_{today}.json"
    with open(path, "w", encoding="utf-8") as f:
        json.dump(snapshot, f, ensure_ascii=False, indent=2)
    # Keep last 30 snapshots
    for old in sorted(SNAPSHOTS_DIR.glob("snapshot_*.json"))[:-30]:
        old.unlink()


def load_snapshot(days_ago: int = 7) -> dict:
    """Load a previous snapshot for comparison."""
    target = (datetime.now() - timedelta(days=days_ago)).strftime("%Y%m%d")
    exact = SNAPSHOTS_DIR / f"snapshot_{target}.json"
    if exact.exists():
        with open(exact, encoding="utf-8") as f:
            return json.load(f)
    # Find closest available
    files = sorted(SNAPSHOTS_DIR.glob("snapshot_*.json"))
    if not files:
        return {}
    # Find closest to target date
    best = files[0]
    for f in files:
        date_str = f.stem.split("_")[1]
        if date_str <= target:
            best = f
    with open(best, encoding="utf-8") as f:
        return json.load(f)


def compute_growth(repos: list, days: int = 7) -> list:
    """Compute star growth vs previous snapshot."""
    prev = load_snapshot(days)
    if not prev:
        return repos

    for r in repos:
        name = r.get("full_name", "")
        if name in prev:
            old_stars = prev[name].get("stars", 0)
            current = r.get("stars", 0)
            diff = current - old_stars
            r["star_growth"] = diff
            r["star_growth_pct"] = round((diff / old_stars * 100), 1) if old_stars > 0 else 0.0
        else:
            r["star_growth"] = None
            r["star_growth_pct"] = None
    return repos


# ─── Formatting ───────────────────────────────────────────

def format_discovery_table(repos: list) -> str:
    lines = [
        "| # | 專案 | Stars | 增長 | 語言 | 分類 | 適合度 | 說明 |",
        "|---|------|-------|------|------|------|--------|------|",
    ]
    for i, r in enumerate(repos, 1):
        if "error" in r:
            continue
        rel = r.get("relevance", {})
        cats = rel.get("categories", classify_repo(r))
        cat_label = CATEGORIES.get(cats[0][0], {}).get("label", cats[0][0]) if cats else "-"
        # Truncate label
        cat_label = cat_label[:12]
        score = rel.get("total_score", r.get("compatibility", {}).get("score", "-"))
        growth = r.get("star_growth")
        growth_str = f"+{growth:,}" if growth and growth > 0 else (str(growth) if growth else "-")
        desc = (r.get("description") or "")[:35]
        lines.append(
            f"| {i} | **{r.get('full_name', '')}** "
            f"| {r.get('stars', 0):,} "
            f"| {growth_str} "
            f"| {r.get('language', '-')} "
            f"| {cat_label} "
            f"| {score}/100 "
            f"| {desc} |"
        )
    return "\n".join(lines)


def format_category_section(category_id: str, repos: list) -> str:
    cat = CATEGORIES.get(category_id, {"label": category_id})
    lines = [f"### {cat['label']}", ""]
    if not repos:
        lines.append("_本週無新發現_")
        return "\n".join(lines)
    lines.append(format_discovery_table(repos))
    return "\n".join(lines)


def format_full_report(report: dict) -> str:
    lines = [
        f"# GitHub 趨勢追蹤報告",
        f"",
        f"**掃描時間：** {report['generated_at'][:19].replace('T', ' ')} UTC",
        f"**追蹤專案：** {report['summary']['tracked_count']}",
        f"**新發現：** {report['summary']['discovered_count']}",
        f"**高度相關：** {report['summary']['high_relevance']}",
        f"",
    ]

    # Top picks
    top = report.get("top_picks", [])
    if top:
        lines.append("## 本週精選（最值得關注）")
        lines.append("")
        for i, r in enumerate(top, 1):
            rel = r.get("relevance", {})
            cats = rel.get("categories", [("?", 0)])
            cat_labels = [CATEGORIES.get(c[0], {}).get("label", c[0]) for c in cats]
            growth = r.get("star_growth")
            growth_str = f" | 週增 +{growth:,}" if growth and growth > 0 else ""
            lines.append(
                f"**{i}. [{r['full_name']}]({r.get('url', '')})** "
                f"— {r.get('stars', 0):,} stars{growth_str}"
            )
            lines.append(f"   {r.get('description', '')}")
            lines.append(f"   分類：{', '.join(cat_labels)} | 適合度：{rel.get('total_score', '-')}/100")
            lines.append("")

    # By category
    categorized = report.get("by_category", {})
    if categorized:
        lines.append("## 分類瀏覽")
        lines.append("")
        for cat_id in CATEGORIES:
            cat_repos = categorized.get(cat_id, [])
            if cat_repos:
                lines.append(format_category_section(cat_id, cat_repos))
                lines.append("")

    # Tracked repos status
    tracked = report.get("tracked_repos", [])
    if tracked:
        lines.append("## 追蹤專案狀態")
        lines.append("")
        lines.append(format_discovery_table(tracked))
        lines.append("")

    return "\n".join(lines)


# ─── Core Commands ────────────────────────────────────────

def cmd_trending(args):
    """Find trending repos across all user interest categories."""
    all_repos = []
    seen = set()

    for cat_id, cat in CATEGORIES.items():
        for query in cat["queries"][:1]:  # First query per category to save API calls
            results = search_recent_trending(query, days=args.days, per_page=args.limit)
            for r in results:
                if "error" not in r:
                    name = r.get("full_name", "")
                    if name and name not in seen:
                        seen.add(name)
                        r["relevance"] = score_user_relevance(r)
                        all_repos.append(r)
            time.sleep(0.8)

    all_repos.sort(key=lambda x: x.get("relevance", {}).get("total_score", 0), reverse=True)
    all_repos = all_repos[:args.limit * 2]

    if args.snapshot:
        save_snapshot(all_repos)

    return all_repos


def cmd_discover(args):
    """Broad discovery: stars-based + recent trending, classified."""
    all_repos = []
    seen = set()

    # Phase 1: Top starred in each category
    for cat_id, cat in CATEGORIES.items():
        query = cat["queries"][0] if cat["queries"] else cat_id
        results = search_repos(query, sort="stars", per_page=5)
        for r in results:
            if "error" not in r:
                name = r.get("full_name", "")
                if name and name not in seen:
                    seen.add(name)
                    r["relevance"] = score_user_relevance(r)
                    all_repos.append(r)
        time.sleep(0.6)

    # Phase 2: Recently trending
    for cat_id, cat in CATEGORIES.items():
        query = cat["queries"][0] if cat["queries"] else cat_id
        results = search_recent_trending(query, days=14, per_page=5)
        for r in results:
            if "error" not in r:
                name = r.get("full_name", "")
                if name and name not in seen:
                    seen.add(name)
                    r["relevance"] = score_user_relevance(r)
                    all_repos.append(r)
        time.sleep(0.6)

    all_repos.sort(key=lambda x: x.get("relevance", {}).get("total_score", 0), reverse=True)

    if args.snapshot:
        save_snapshot(all_repos)

    return all_repos


def cmd_full_report(args):
    """Generate comprehensive report with classification."""
    # Discover
    dummy_args = argparse.Namespace(days=14, limit=10, snapshot=True, format="json")
    all_repos = cmd_discover(dummy_args)

    # Compute growth
    all_repos = compute_growth(all_repos, days=7)

    # Track known repos
    tracked = []
    for repo_name in TRACKED_REPOS:
        info = get_repo_info(repo_name)
        if "error" not in info:
            info["relevance"] = score_user_relevance(info)
            tracked.append(info)
        time.sleep(0.5)
    tracked = compute_growth(tracked, days=7)

    # Classify into categories
    by_category = {}
    for r in all_repos:
        cats = r.get("relevance", {}).get("categories", classify_repo(r))
        for cat_id, conf in cats:
            if cat_id not in by_category:
                by_category[cat_id] = []
            by_category[cat_id].append(r)

    # Top picks: highest relevance
    top_picks = [r for r in all_repos if r.get("relevance", {}).get("total_score", 0) >= 50][:10]

    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "tracked_repos": tracked,
        "discoveries": all_repos,
        "top_picks": top_picks,
        "by_category": by_category,
        "summary": {
            "tracked_count": len(tracked),
            "discovered_count": len(all_repos),
            "high_relevance": len(top_picks),
            "categories_found": len([c for c in by_category if by_category[c]]),
        },
    }

    # Cache
    save_cache(report, "full_report")
    save_snapshot(all_repos + tracked)

    return report


# ─── Legacy commands ──────────────────────────────────────

def cmd_search(args):
    if args.topic:
        results = search_repos(f"topic:{args.topic}", per_page=args.limit)
    elif args.query:
        results = search_repos(args.query, per_page=args.limit)
    else:
        results = []
        for cat_id, cat in CATEGORIES.items():
            results.extend(search_repos(cat["queries"][0], per_page=3))
            time.sleep(0.5)
    for r in results:
        if "error" not in r:
            r["relevance"] = score_user_relevance(r)
    return results


def cmd_analyze(args):
    info = get_repo_info(args.repo)
    if "error" not in info:
        info["relevance"] = score_user_relevance(info)
    return info


def cmd_track(args):
    results = []
    for repo_name in TRACKED_REPOS:
        info = get_repo_info(repo_name)
        if "error" not in info:
            info["relevance"] = score_user_relevance(info)
        results.append(info)
        time.sleep(0.5)
    results = compute_growth(results, days=7)
    return results


# ─── Cache ────────────────────────────────────────────────

def save_cache(data, name: str):
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    cache_file = CACHE_DIR / f"{name}_{datetime.now().strftime('%Y%m%d')}.json"
    with open(cache_file, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2, default=str)
    for old in sorted(CACHE_DIR.glob(f"{name}_*.json"))[:-7]:
        old.unlink()


# ─── Main ─────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="GitHub Monitor v2 for OpenClaw")
    sub = parser.add_subparsers(dest="command")

    # search
    sp = sub.add_parser("search", help="Search repos by query or topic")
    sp.add_argument("--query", "-q", help="Search query")
    sp.add_argument("--topic", "-t", help="Search by topic")
    sp.add_argument("--limit", "-n", type=int, default=15)
    sp.add_argument("--format", choices=["json", "table"], default="table")

    # trending
    sp = sub.add_parser("trending", help="Find trending repos in your interest areas")
    sp.add_argument("--days", "-d", type=int, default=7, help="Look back N days")
    sp.add_argument("--limit", "-n", type=int, default=10)
    sp.add_argument("--snapshot", action="store_true", default=True)
    sp.add_argument("--format", choices=["json", "table"], default="table")

    # discover
    sp = sub.add_parser("discover", help="Broad discovery across all categories")
    sp.add_argument("--days", "-d", type=int, default=14)
    sp.add_argument("--limit", "-n", type=int, default=10)
    sp.add_argument("--snapshot", action="store_true", default=True)
    sp.add_argument("--format", choices=["json", "table"], default="table")

    # analyze
    sp = sub.add_parser("analyze", help="Deep analyze a specific repo")
    sp.add_argument("--repo", "-r", required=True, help="owner/repo")
    sp.add_argument("--format", choices=["json", "table"], default="json")

    # track
    sp = sub.add_parser("track", help="Check status of tracked repos")
    sp.add_argument("--format", choices=["json", "table"], default="table")

    # report (full)
    sp = sub.add_parser("report", help="Full report: trending + tracked + classified")
    sp.add_argument("--format", choices=["json", "markdown"], default="markdown")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)

    fmt = getattr(args, "format", "json")

    if args.command == "search":
        data = cmd_search(args)
        if fmt == "json":
            print(json.dumps(data, ensure_ascii=False, indent=2, default=str))
        else:
            print(format_discovery_table(data))

    elif args.command == "trending":
        data = cmd_trending(args)
        if fmt == "json":
            print(json.dumps(data, ensure_ascii=False, indent=2, default=str))
        else:
            print(format_discovery_table(data))

    elif args.command == "discover":
        data = cmd_discover(args)
        if fmt == "json":
            print(json.dumps(data, ensure_ascii=False, indent=2, default=str))
        else:
            print(format_discovery_table(data))

    elif args.command == "analyze":
        data = cmd_analyze(args)
        if fmt == "json":
            print(json.dumps(data, ensure_ascii=False, indent=2, default=str))
        else:
            print(format_discovery_table([data]))

    elif args.command == "track":
        data = cmd_track(args)
        if fmt == "json":
            print(json.dumps(data, ensure_ascii=False, indent=2, default=str))
        else:
            print(format_discovery_table(data))

    elif args.command == "report":
        data = cmd_full_report(args)
        if fmt == "json":
            print(json.dumps(data, ensure_ascii=False, indent=2, default=str))
        else:
            print(format_full_report(data))


if __name__ == "__main__":
    main()
