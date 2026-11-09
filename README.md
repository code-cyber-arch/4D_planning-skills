# Construction timeline builder for After Effects

A skill that builds the animated timeline strips, activity trackers, cash flow charts and key dates tickers that sit under 4D BIM flythroughs.

You give Claude the programme and a screenshot. You get back a script that builds the whole thing in After Effects.

**You do not need any coding knowledge to use this.** Installing takes about two minutes, and you only do it once.

---

## Install it

### Step 1 — Turn on code execution

Claude needs this switched on before it will accept any skill.

1. Open Claude and click your name in the bottom-left corner.
2. Click **Settings**, then **Capabilities**.
3. Turn on **Code execution and file creation**.

> **On a company account?** You may not see this switch. If not, ask whoever manages your company's Claude account to turn on **Code execution and file creation** and **Skills** in the organisation settings. You cannot do this part yourself.

### Step 2 — Download the skill file

Download **[timeline-jsx.zip](dist/timeline-jsx.zip)**.

On this page, click the file name above, then click the **Download** button. It will land in your Downloads folder.

**Do not unzip it.** Claude wants the zip exactly as it is.

### Step 3 — Add it to Claude

1. Click your name in the bottom-left corner again.
2. Click **Customize**, then **Skills**.
3. Click the **+** button.
4. Click **+ Create skill**.
5. Click **Upload a skill**.
6. Choose the `timeline-jsx.zip` you just downloaded.

"timeline-jsx" now appears in your skills list. Make sure its switch is turned **on**.

### Done

It works in every future chat, on any computer you sign in from. You never have to do this again.

---

## Check it worked

Start a new chat and type:

> Can you build a construction timeline strip?

If Claude answers by asking you for the programme file and a Synchro screenshot, it's installed correctly.

If Claude instead gives a general answer about construction timelines without asking for your files, it isn't picking the skill up. Go back to **Customize > Skills** and check the switch next to "timeline-jsx" is on.

---

## Now use it

Full instructions for building a timeline are in **[how-to-use-timeline-jsx.md](AE/timeline/how-to-use-timeline-jsx.md)** — what files to have ready, what to ask for, how to run the finished script in After Effects, and how to get a timeline updated when the programme changes.

---

## Updating to a newer version

If the skill gets improved and you're told to update:

1. Download the new **[timeline-jsx.zip](dist/timeline-jsx.zip)** from this page.
2. Go to **Customize > Skills**.
3. Delete the old "timeline-jsx" entry.
4. Upload the new zip the same way as Step 3 above.

---

## For developers

The skill lives in the standard layout, so cloning this repo gives a working project-scoped skill with no install step:

```
.claude/skills/
└── timeline-jsx/
    └── SKILL.md
```

To install it globally for Claude Code instead, symlink it:

```bash
mkdir -p ~/.claude/skills/timeline-jsx
ln -sfn "$PWD/.claude/skills/timeline-jsx/SKILL.md" ~/.claude/skills/timeline-jsx/SKILL.md
```

Restart your session afterwards — skills are loaded at startup.

### Maintaining the zip

The zip in `dist/` is generated, so it does not update itself. After editing the skill, rebuild and commit the zip alongside the edit, or people will download a stale skill:

```bash
./build-zip.sh
```
