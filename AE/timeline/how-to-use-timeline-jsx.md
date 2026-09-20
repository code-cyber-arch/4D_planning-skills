# How to use the "timeline-jsx" skill

A quick guide for building or updating a construction timeline video overlay. No coding knowledge needed.

## 1. Install it (one time only)

When Claude proposes the "timeline-jsx" skill in a chat, you'll see a review card. Click **Save**. That's it — it's now available in every future chat on this Claude account, on any computer you use it from.

## 2. What to have ready before you ask

Three things:

1. **The programme file** — the MS Project or Primavera P6 export (XML) for the project.
2. **A screenshot** of the Synchro timeline summary from the Animation ribbon.
3. **The brand colours** — either the client's name and website, or a logo/brand image. (Skip this if you've already built a timeline for this client before — Claude will remember their colours.)

## 3. Ask for it

Just describe what you want and attach the files, for example:

> "Build the timeline strip for [Client] — [Project name]"

with the programme XML and the Synchro screenshot attached, plus the brand name/website or logo if it's a new client.

## 4. What happens next

- If anything's missing, Claude will ask for it.
- For a **new client**, you'll first see an interactive preview in your browser — check the colours, layout, and dates look right before giving the go-ahead. A few rounds of "move this," "change that" is normal.
- For a **returning client**, it goes straight to the final file since the look is already settled.
- You'll get two files: the script itself (a `.jsx` file) and a short notes file (a `.md` file) explaining what's in it.

## 5. Running the script in After Effects

1. Open your After Effects project.
2. Go to **File > Scripts > Run Script File...**
3. Select the `.jsx` file you were given.
4. Click through the summary pop-up that appears.
5. The finished timeline shows up as a new composition in your Project panel.

## 6. Placing it in your video

1. Drag the new composition into your main 1920×1080 comp.
2. Position it so the bottom edge sits exactly at the bottom of the frame.
3. Turn on **Collapse Transformations** for that layer.

## 7. Updating a timeline later

If the programme changes or the animation timing changes:

1. Send Claude the **previous** `.jsx` file, plus the **new** programme XML (and a new screenshot if the timing changed too).
2. Say it's an **update**, not a new build.
3. You'll get a new version of the script. The old one is left untouched, so you can compare if needed.

## 8. If a colour or preference needs to change later

Just tell Claude directly (e.g. "actually use this colour instead" or "always use full milestone names for this client"). It'll apply the change and offer to save it as the new standard for that client, so you won't have to repeat yourself next time.
