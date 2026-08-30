---
title: "RustPress 配置与使用指南"
cover: "assets/cover.png"
layout: columns
description: "RustPress 深度指南：涵盖安装、自动化部署、核心配置、创作，以及主题定制开发。"
product_id: "yishulun.com_columns_rustpress"
price: 0.0
draft: false
tags: ['RustPress', '静态博客', 'Rust', '主题开发', '配置指南', '倒分页']
catalog:
  - "一、安装与快速上手"
  - "1.1.安装与本地开发预览.md"
  - "1.2.GitHub-CI-CD自动化部署.md"
  - "1.3.Cloudflare全球加速与免刷缓存配置.md"
  - "二、核心配置详解"
  - "2.1.全局基础配置与config.toml详解.md"
  - "2.2.谷歌统计(Google-Analytics)配置.md"
  - "2.3.谷歌广告(Google-AdSense)配置.md"
  - "2.4.GitHub原生评论与点赞系统配置.md"
  - "2.5.专栏与分类法路径配置.md"
  - "2.6.独立域名与CNAME解析配置.md"
  - "三、内容创作说明"
  - "3.1.日常博客文章写作指南.md"
  - "3.2.系统化专栏与连载体系指南.md"
  - "3.3.短动态闲言(Tweets)发布指南.md"
  - "3.4.友情链接(Friends)添加与管理.md"
  - "3.5.个人著作(Works)展示与管理.md"
  - "3.6.开源项目(Projects)展示与管理.md"
  - "3.7.作者简介(About)页面定制.md"
  - "3.8.命令行创作指南.md"
  - "四、主题定制开发"
  - "4.1.主题架构设计与default-light主题对比.md"
  - "4.2.模板系统速查与用途详解.md"
  - "4.3.Tera模板引擎语法与全局上下文变量.md"
  - "4.4.从零开发与自定义专属主题.md"
  - "4.5.专属定制服务.md"
createTime: "2026-08-28 10:00:00"
---

# RustPress 配置与使用指南

**RustPress** 是一款由作者金石碼农用 Rust 语言打造的开源、高性能、纯静态、零后端依赖的现代静态博客程序。它具备毫秒级增量编译、独创倒分页算法、多元内容模板（博客、专栏、闲言、著作、项目、友链）、现代化 Tera 前端模板与 Tailwind CSS 主题体系。

- GitHub 仓库：https://github.com/rixingyike/rustpress
- Crates.io 类库：https://crates.io/crates/rustpress

除了采用 Rust 语言编写，具有高性能、高运行安全性特征外，RustPress 相比其他博客程序还有两个明显的特征：
- 采用自创的倒分页布局，新生成的内容永远在新页面，已经生成的旧页面永远不会动。
- 采用增量编译机制，每次只编译新生成的内容，而不是重新编译整个网站。

有这两个特征，RustPress 保证了编译 100 篇文章和编译 10000 篇文章是一样的快，RustPress 不会越用越慢。事实上，你用 RustPress 发布第 1 章文章，与发布第 10000 章文章，体验是没有差别的。

本专栏详细介绍 RustPress 的配置、使用与定制方法，内容由作者亲自编写和审校，共分为四大部分：一、安装与部署；二、核心配置；三、内容创作；四、主题定制。
