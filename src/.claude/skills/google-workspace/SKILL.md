---
name: google-workspace
description: Read and edit Google Docs, Sheets, Slides, and Forms, and find, export, or copy files in Google Drive, by calling the Google REST APIs directly. Use when the user shares a docs.google.com or drive.google.com URL or a file ID, or asks to read, create, or update a document, spreadsheet, presentation, or form.
argument-hint: '[login]'
allowed-tools: Bash
---

# Google Workspace

## Mode: Login

When this skill is invoked with the argument `login`: run `${CLAUDE_SKILL_DIR}/scripts/api.py login` with the longest Bash timeout. It opens the browser and waits for the user to approve access; tell the user to complete it there. Report the result and stop.

## Mode: Request (default)

Every call goes through one script, which attaches and refreshes the OAuth token. Never read or print the token file.

```sh
${CLAUDE_SKILL_DIR}/scripts/api.py <METHOD> '<URL>' [-o <file>]
${CLAUDE_SKILL_DIR}/scripts/api.py POST '<URL>' <<'JSON'
{"requests": [...]}
JSON
```

- Single-quote the URL, since `fields` masks contain parentheses. The request body is read from stdin
- Non-2xx: exit code 1, the API error JSON on stderr. Read the error message before retrying
- Empty collections are omitted from a response, not returned as `[]`, so guard `jq` iteration (`.items // [] | .[]`)
- Large unpiped output is saved to a temp file; only its path and head are printed, so query that file with `jq`. Piped output (`| jq`) is never cut. To save a response, use `-o <file>`, not `>`
- `Not logged in` or `Token lacks required scopes`: stop and ask the user to run `/google-workspace login`

The API calls are fast; the slow part is each separate Bash tool call, which costs a full model turn. Put independent calls in one Bash command (chain them, or run reads in parallel with `&` and `wait`), and prefer batch endpoints: one `batchUpdate` with many requests, Sheets `values:batchGet` / `values:batchUpdate` for several ranges.

Confirm with the user before any POST, PATCH, PUT, or DELETE they have not already asked for. `batchUpdate` is atomic: one invalid request fails the whole batch, and its reply carries the new object IDs; Forms also returns the updated form with `"includeFormInResponse": true`, which saves a verification GET.

## APIs

| API | Base URL |
|---|---|
| Docs | `https://docs.googleapis.com/v1/documents` |
| Sheets | `https://sheets.googleapis.com/v4/spreadsheets` |
| Slides | `https://slides.googleapis.com/v1/presentations` |
| Forms | `https://forms.googleapis.com/v1/forms` |
| Drive | `https://www.googleapis.com/drive/v3/files` |

The file ID is the URL segment after `/d/`. For Forms, use the edit ID, not the `/forms/d/e/<ID>/viewform` responder ID. Add `supportsAllDrives=true` to Drive calls (and `includeItemsFromAllDrives=true` to searches) so shared drives work.

Before guessing a request shape, read the Discovery document through the script, e.g. `GET 'https://docs.googleapis.com/$discovery/rest?version=v1' | jq '.schemas.InsertTextRequest'` (Sheets is `version=v4`; Drive is `https://www.googleapis.com/discovery/v1/apis/drive/v3/rest`).

## Keeping Responses Small

- Read a Doc with `GET <Drive>/<ID>/export?mimeType=text/markdown`; call `documents.get` only when `batchUpdate` needs character indexes. The export holds every tab, each under its title as an H1; map a URL's `?tab=t.xxx` to a title with `documents/<ID>?includeTabsContent=true&fields=tabs(tabProperties(tabId,title),childTabs(tabProperties(tabId,title)))`. The export escapes Markdown characters in headings (`_` becomes `\_`), so match titles loosely
- Pass `fields=` on every `get`, e.g. Slides `fields=slides(objectId,pageElements(objectId,shape/text/textElements/textRun/content))`, or Sheets cell types and formats `?ranges=<range>&includeGridData=true&fields=sheets(data(rowData(values(formattedValue,effectiveValue,effectiveFormat/numberFormat))))`
- `create` returns the whole new file; append `?fields=documentId` (or `spreadsheetId`, `presentationId`, `formId`)

## Pitfalls

- Do not assume a sheet title such as `Sheet1`; read the actual titles with `?fields=sheets.properties(title)` and URL-encode the range
- Appending a row with `values/<range>:append?valueInputOption=USER_ENTERED&insertDataOption=INSERT_ROWS` inherits the column's existing number format; send dates and numbers as bare values, not strings, to match the rows already there. A plain `values` read returns formatted strings, so check the stored types with `includeGridData` first
- Slides object IDs you assign must be 5 to 50 characters
- Forms `create` accepts only `info.title` and `info.documentTitle`; the Drive file name comes from `documentTitle`. Add items with `batchUpdate`
