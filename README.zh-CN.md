# XCrawl Skills

面向多智能体运行时的可复用 XCrawl Skill 定义，聚焦 API-first 的网页数据工作流。
仓库地址：`https://github.com/xcrawl-api/xcrawl-skills`

[English](README.md) | 中文

## 什么是 XCrawl

XCrawl 是用于搜索、页面抓取、URL 映射与站点爬取的网页数据基础设施产品。
本仓库提供可用于生产场景的 Skill 定义，帮助智能体以统一方式调用 XCrawl API。

## 本仓库提供什么

- 覆盖常见 XCrawl 工作流的可直接复用 Skills
- 面向 API 的说明（包含请求/返回参数）
- 适合运行时直接执行的 cURL 与 Node 示例
- 多智能体编排可复用的一致契约

## Skill 列表

- `xcrawl-scrape`: 单 URL 抽取与结构化数据工作流
- `xcrawl-map`: 站点 URL 发现与范围规划工作流
- `xcrawl-crawl`: 站点批量爬取与异步结果处理工作流
- `xcrawl-search`: 带 location/language 控制的查询发现工作流

## 快速开始

### 1. 前置条件

- 可用的 XCrawl API Key
- 运行时命令：`curl` 与 `node`
- 可访问本仓库

### 2. 配置本地 API Key

创建本地配置文件：

路径：`~/.xcrawl/config.json`

```json
{
  "XCRAWL_API_KEY": "<your_api_key>"
}
```

本仓库内 skills 统一从该本地文件读取 `XCRAWL_API_KEY`。

### 3. 选择 Skill

打开以下任一文件：

- `skills/xcrawl-scrape/SKILL.md`
- `skills/xcrawl-map/SKILL.md`
- `skills/xcrawl-crawl/SKILL.md`
- `skills/xcrawl-search/SKILL.md`

每个 skill 均包含：

- 适用场景
- 请求参数
- 返回参数
- cURL / Node 示例

### 4. 发起请求

直接使用各 `SKILL.md` 里的示例，再按你的业务需求调整请求 payload。

## 典型用户意图

- “以 sync 模式抓取这个页面，并返回 markdown + links。”
- “只映射该域名下 `/docs/` 的 URL，limit 设为 2000。”
- “发起一个有边界的 crawl（depth 2、limit 100），轮询到完成。”
- “以美式英语搜索这个 query，返回前 20 条结果。”

## 跨 Agent 契约

每个 skill 都可以通过运行时适配层执行。

- 输入标准化：`goal`, `inputs`, `constraints`, `credentials_ref`, `runtime_context`
- 输出标准化：`status`, `request_payload`, `raw_response` 或异步双响应, `task_ids`, `error`

默认行为是原样透传上游 API 响应。

## XCrawl 通用约定

- Base URL: `https://run.xcrawl.com`
- 本地配置文件: `~/.xcrawl/config.json`
- 本地配置中的 API Key 字段: `XCRAWL_API_KEY`
- 鉴权头: `Authorization: Bearer <XCRAWL_API_KEY>`
- 主要端点:
  - `POST /v1/scrape` 与 `GET /v1/scrape/{scrape_id}`
  - `POST /v1/map`
  - `POST /v1/crawl` 与 `GET /v1/crawl/{crawl_id}`
  - `POST /v1/search`

## 支持

- [XCrawl 官网](https://www.xcrawl.com/)
- [XCrawl 文档](https://docs.xcrawl.com/)
