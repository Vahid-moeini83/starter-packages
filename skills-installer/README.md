# Skills Installer

نصب دسته‌جمعی Agent Skills روی سیستم — یک‌بار در هر سیستم (global)، مستقل
از پکیج‌های `frontend-starter` / `backend-starter`.

این پوشه فقط با اسکریپت مستقیم اجرا می‌شود و **هرگز** جزو پکیج‌های npm که
publish می‌شوند نیست (چون در فیلد `files` آن پکیج‌ها ذکر نشده). پس نصب
`frontend-starter` یا `backend-starter` هیچ ربطی به این اسکریپت ندارد و
باعث نصب اسکیل‌ها نمی‌شود — این دو کاملاً جدا هستند.

## روال استفاده (خیلی ساده)

### 🖥️ ویندوز (PowerShell)

**برای فرانت‌اند + مشترک‌ها:**
```powershell
irm https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.ps1 -OutFile install.ps1; .\install.ps1 -Mode frontend
```

**برای بک‌اند + مشترک‌ها:**
```powershell
irm https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.ps1 -OutFile install.ps1; .\install.ps1 -Mode backend
```

### 🐧 لینوکس / مک (bash)

**برای فرانت‌اند + مشترک‌ها:**
```bash
curl -fsSL https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.sh | bash -s frontend
```

**برای بک‌اند + مشترک‌ها:**
```bash
curl -fsSL https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.sh | bash -s backend
```

> نکته: نسخه bash به `jq` نیاز دارد (`sudo apt install jq` یا `brew install jq`).
> نسخه PowerShell نیازی به ابزار جانبی ندارد.

## این دو دستور دقیقاً چه کاری می‌کنند؟

هرکدام، اسکیل‌های `shared` را همیشه شامل می‌شوند، به‌علاوه دسته‌ی انتخابی:

| دستور | نصب می‌کند |
|---|---|
| `-Mode frontend` / `bash -s frontend` | اسکیل‌های frontend + shared |
| `-Mode backend` / `bash -s backend` | اسکیل‌های backend + shared |

اسکریپت خودش لیست (`skills-manifest.json`) را مستقیم از گیت‌هاب دانلود
می‌کند، پس نیازی به کلون کردن ریپو نیست — فقط همان یک خط دستور کافی است.

## نکته: نصب بدون هیچ سوال تعاملی

ابزار زیرین (`npx skills add`) به‌صورت پیش‌فرض هر بار یک سوال تعاملی
می‌پرسد («این skill را برای کدام agent(ها) نصب کنم؟»). اسکریپت‌های این
پوشه این سوال را با پرچم‌های زیر از قبل جواب داده‌اند، تا کل فرآیند
بدون هیچ توقف یا ورودی دستی کامل شود:

```
-g -a claude-code -a cursor -a kiro-cli -y
```

یعنی هر skill به‌صورت **global** و برای سه ابزار **Claude Code، Cursor،
و Kiro CLI** نصب می‌شود، بدون نمایش هیچ تاییدیه‌ای. اگر بعداً خواستید
agent دیگری (مثلاً `codex` یا `opencode`) هم اضافه شود، کافی‌ست همین
بخش را در `install.sh` و `install.ps1` ویرایش کنید.

## اضافه کردن Skill جدید (برای نگهداری آینده)

کافی است در فایل `skills-manifest.json` این ریپو، یک آیتم جدید به دسته‌ی
مربوطه (`frontend`, `backend`, یا `shared`) اضافه و روی گیت‌هاب push کنید:

```json
{
  "name": "اسم-اسکیل",
  "source": "https://github.com/owner/repo",
  "skill": "نام-دقیق-اسکیل-در-ریپو"
}
```

اگر ریپوی مرجع فقط یک skill دارد و نیازی به فلگ `--skill` نیست، مقدار
`skill` را `null` بگذارید. نیازی به تغییر `install.sh` یا `install.ps1`
نیست — همه‌ی اعضای تیم با اجرای دوباره‌ی همان دستور بالا، نسخه‌ی جدید
manifest را می‌گیرند.

## وضعیت فعلی Manifest

آیتم `non-agents-official` هنوز `source: null` دارد و در زمان اجرا
به‌صورت خودکار **رد (skip)** می‌شود؛ در خلاصه‌ی پایانی اجرای اسکریپت زیر
عنوان «رد شده» نمایش داده می‌شود. با پیدا کردن مرجع درست آن، کافی‌ست
manifest را تکمیل و push کنید.
