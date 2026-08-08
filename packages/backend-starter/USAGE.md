# راهنمای استفاده

بعد از اجرای دستور init، یک پوشه `.ai-starter/` در ریشه پروژه شما ساخته می‌شود که شامل موارد زیر است:

- `.ai-starter/skills/` — مجموعه Skillهای آماده
- `.ai-starter/context/` — قوانین و Contextهای پروژه (Rules)
- `.ai-starter/mcp/` — تنظیمات MCP (در حال تکمیل)

## چطور این فایل‌ها به ابزار AI من متصل می‌شوند؟

این پوشه به تنهایی توسط ابزارهای AI خونده نمی‌شود، مگر اینکه به آن‌ها معرفی شود. در زمان اجرای `init`، بسته به انتخاب شما، فایل‌های راهنمای کوچکی در مسیرهای زیر ساخته می‌شود که به `.ai-starter/` اشاره می‌کنند:

| ابزار       | فایل ساخته‌شده                 |
| ----------- | ------------------------------ |
| Cursor      | `.cursor/rules/ai-starter.mdc` |
| Claude Code | `CLAUDE.md` (بخش اضافه‌شده)    |
| Kiro        | `.kiro/steering/ai-starter.md` |

اگر ابزار دیگری استفاده می‌کنید که در لیست بالا نیست، می‌توانید به صورت دستی در فایل تنظیمات همان ابزار، ارجاعی به پوشه `.ai-starter/` اضافه کنید.

## اضافه کردن Skill یا Context جدید

کافیست یک پوشه/فایل جدید داخل `.ai-starter/skills/` یا `.ai-starter/context/` اضافه کنید. نیازی به تغییر فایل‌های reference نیست، چون آن‌ها به کل پوشه اشاره می‌کنند نه به فایل‌های مشخص.

## نصب و استفاده

```bash
# نصب با npx (توصیه می‌شود)
npx backend-starter init

# یا نصب global
npm install -g backend-starter
backend-starter init
```

## ساختار فایل‌های ایجاد شده

```
your-project/
├── .ai-starter/
│   ├── skills/
│   │   ├── laravel-specialist/
│   │   │   └── SKILL.md
│   │   ├── laravel-security/
│   │   └── ...
│   ├── context/
│   │   ├── database.md
│   │   ├── api-standards.md
│   │   └── ...
│   └── mcp/
│       └── .gitkeep
│
├── .cursor/                    # اگر Cursor انتخاب شده باشد
│   └── rules/
│       └── ai-starter.mdc
│
├── .kiro/                      # اگر Kiro انتخاب شده باشد
│   └── steering/
│       └── ai-starter.md
│
└── CLAUDE.md                   # اگر Claude Code انتخاب شده باشد
```
