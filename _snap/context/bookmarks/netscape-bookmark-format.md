# Netscape Bookmark File Format Specification

**Source:** [Microsoft Learn - Internet Explorer Platform APIs](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/aa753582(v=vs.85))

## Overview

The Windows Internet Explorer Favorites structure mirrors the Netscape Bookmark format. Netscape stores bookmarks in an HTML file, typically named `Bookmark.htm`. This format has become a de facto standard for bookmark interchange between browsers.

## File Structure

### Header
Bookmark files begin with a DOCTYPE declaration and metadata:

```html
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!--This is an automatically generated file.
It will be read and overwritten.
Do Not Edit! -->
<Title>Bookmarks</Title>
<H1>Bookmarks</H1>
```

### Main Container
The bookmark collection is wrapped in a definition list (`<DL>`):

```html
<DL>
{item}
{item}
</DL>
```

Each item in the definition list is a definition term (`<DT>`) containing either:
- A folder (subfolder heading with nested list)
- A bookmark (anchor link)
- A separator (horizontal rule)

## Item Types

### Folders (Subfolders)
Nested collections use the `H3` heading tag with attributes:

```html
<DT><H3 FOLDED ADD_DATE="{date}">{title}</H3>
<DL><p>
    {item}
</DL><p>
```

**Attributes:**
- `FOLDED` - Indicates the folder can be collapsed (optional)
- `ADD_DATE` - Unix timestamp when folder was created
- `LAST_MODIFIED` - Unix timestamp when folder was last modified (optional)
- `PERSONAL_TOOLBAR_FOLDER` - Special attribute for the bookmarks bar/toolbar folder

### Bookmarks (Shortcuts)
Individual links use the anchor tag structure:

```html
<DT><A HREF="{url}" ADD_DATE="{date}" LAST_VISIT="{date}"
LAST_MODIFIED="{date}">{title}</A>
```

**Attributes:**
- `HREF` - URL of the bookmark (required)
- `ADD_DATE` - Unix timestamp when bookmark was created
- `LAST_VISIT` - Unix timestamp of last visit (optional)
- `LAST_MODIFIED` - Unix timestamp when bookmark was last modified (optional)
- `ICON` - Base64-encoded favicon data URI (optional)
- `ICON_URI` - URI reference to favicon (optional)

### Feeds (RSS/Atom)
RSS/feed entries include special attributes:

```html
<DT><A HREF="{url}" FEED="true" FEEDURL="{feed_url}">{title}</A>
```

**Attributes:**
- `FEED` - Boolean flag indicating this is a feed subscription
- `FEEDURL` - URL of the actual feed XML

### Web Slices
Dynamic content sections use:

```html
<DT><A HREF="{url}" WEBSLICE="true" ISLIVEPREVIEW="true"
PREVIEWSIZE="{width}x{height}">{title}</A>
```

**Attributes:**
- `WEBSLICE` - Boolean flag for web slice content
- `ISLIVEPREVIEW` - Indicates live preview is enabled
- `PREVIEWSIZE` - Dimensions for preview window (e.g., "400x300")

### Separators
Visual separators use horizontal rules:

```html
<DT><HR>
```

## Date Format

All date attributes use **Unix timestamp format**: decimal integers representing seconds since midnight January 1, 1970 UTC (epoch time).

**Example:**
```
ADD_DATE="1605024000"  # November 10, 2020 08:00:00 UTC
```

## Special Attributes

### Icons
Icon associations can be specified in two ways:

1. **Base64 Data URI** (inline):
   ```html
   ICON="data:image/png;base64,iVBORw0KGgo..."
   ```

2. **URI Reference**:
   ```html
   ICON_URI="https://example.com/favicon.ico"
   ```

### Toolbar Folder
The special bookmarks toolbar/bar is marked with:
```html
<H3 PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Bar</H3>
```

## Complete Example

```html
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
    <DT><H3 ADD_DATE="1605024000" LAST_MODIFIED="1700000000" PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Bar</H3>
    <DL><p>
        <DT><H3 ADD_DATE="1605024100" LAST_MODIFIED="1699900000">Programming</H3>
        <DL><p>
            <DT><A HREF="https://docs.python.org/3/" ADD_DATE="1605024300" ICON="data:image/png;base64,iVBORw0KG...">Python Documentation</A>
            <DT><A HREF="https://github.com/" ADD_DATE="1605024900">GitHub</A>
        </DL><p>
        <DT><HR>
        <DT><A HREF="https://news.ycombinator.com/" ADD_DATE="1605025200">Hacker News</A>
    </DL><p>
    <DT><H3 ADD_DATE="1605025900">Other Bookmarks</H3>
    <DL><p>
        <DT><A HREF="https://example.com/" ADD_DATE="1605026300">Example Domain</A>
    </DL><p>
</DL><p>
```

## Key Implementation Notes

1. **Nesting**: Folders can be nested arbitrarily deep using the `<DL>` structure
2. **Whitespace**: The `<p>` tags after `<DL>` and `</DL>` are formatting hints (often ignored by parsers)
3. **Case**: Tag names can be uppercase or lowercase (HTML is case-insensitive)
4. **Encoding**: Files should use UTF-8 encoding
5. **Unclosed Tags**: `<DT>`, `<DD>`, and `<P>` tags are often left unclosed in the wild
6. **Order**: Items appear in the order they're listed within each folder

## Browser-Specific Extensions

Different browsers may add their own attributes:

### Chrome/Chromium
- `ICON` - Base64-encoded favicons
- `PERSONAL_TOOLBAR_FOLDER` - Bookmarks bar marker

### Firefox
- `SHORTCUTURL` - Keyword shortcuts
- `TAGS` - Tag metadata
- `UNFILED_BOOKMARKS_FOLDER` - Unsorted bookmarks folder

### Internet Explorer
- `FEED`, `FEEDURL` - RSS feed support
- `WEBSLICE`, `ISLIVEPREVIEW`, `PREVIEWSIZE` - Web Slice features

## Data Exchange

- **Export:** Applications typically generate this HTML format when exporting bookmarks
- **Import:** Parsers should be lenient with malformed HTML and missing attributes
- **Interchange:** This format is widely supported across browsers for bookmark migration

## Parsing Recommendations

1. Use a proper HTML parser (e.g., BeautifulSoup, lxml) rather than regex
2. Handle missing attributes gracefully with sensible defaults
3. Skip malformed entries rather than failing completely
4. Preserve folder hierarchy by tracking depth during recursive parsing
5. Validate URLs before storage (check for empty or invalid URLs)
6. Handle special URL schemes (javascript:, chrome://, file://) appropriately
