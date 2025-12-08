---
name: extract-pdf-text
description: Extract text content from PDF files using pdfplumber
---

# Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("<path-to-pdf>") as pdf:
    text = pdf.pages[0].extract_text()

    all_text = "\n".join(
        page.extract_text() or "" for page in pdf.pages
    )
```
