# Playwright Licensing and Legal Information

## License Type

**Apache License 2.0**

Playwright is licensed under the Apache License, Version 2.0, one of the most permissive open-source licenses available.

## What This Means

### You CAN:
- ✅ Use Playwright commercially without any fees
- ✅ Modify the source code
- ✅ Distribute the software
- ✅ Sublicense the software
- ✅ Use it privately in your projects
- ✅ Use it in proprietary/closed-source software
- ✅ Patent use (grants patent rights from contributors)

### You MUST:
- ✅ Include the original copyright notice
- ✅ Include the Apache License text
- ✅ State significant changes made to the code
- ✅ Include the NOTICE file if one exists

### You CANNOT:
- ❌ Hold contributors liable for damages
- ❌ Use Playwright's trademarks without permission
- ❌ Expect any warranty or guarantee

## Key License Provisions

### Copyright Grant
"Subject to the terms and conditions of this License, each Contributor hereby grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable copyright license to reproduce, prepare Derivative Works of, publicly display, publicly perform, sublicense, and distribute the Work and such Derivative Works in Source or Object form."

### Patent Grant
"Each Contributor hereby grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable (except as stated in this section) patent license to make, have made, use, offer to sell, sell, import, and otherwise transfer the Work."

### Redistribution Requirements
When distributing Playwright or derivative works:
1. Provide a copy of the Apache License 2.0
2. Keep all copyright, patent, trademark, and attribution notices
3. Include a copy of the NOTICE file if it exists
4. Mark modified files with prominent notices

### Disclaimer of Warranty
**"THE WORK IS PROVIDED 'AS IS', WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied, including, without limitation, any warranties or conditions of merchantability or fitness for a particular purpose."**

### Limitation of Liability
Contributors are not liable for any damages arising from the use or inability to use the software, including direct, indirect, incidental, special, exemplary, or consequential damages.

## Copyright Attribution

Playwright contains code with copyright from:
- **Microsoft Corporation** (primary developer)
- **Google Inc.** (portions from 2017, likely from original Puppeteer team)

Full attribution: "Portions Copyright (c) Microsoft Corporation. Portions Copyright 2017 Google Inc."

## Cost and Pricing

### Core Library (playwright-python)
- **Cost**: **FREE** (completely free, no hidden fees)
- **Commercial use**: Allowed without restrictions
- **No registration required**: Download and use immediately
- **No usage limits**: Use for any number of projects/pages

### Microsoft Playwright Testing (Azure Service)
- **Different product**: Separate paid cloud testing service
- **Optional**: Not required to use Playwright library
- **For enterprise**: Cloud-based parallel testing at scale
- **Pricing**: Based on Azure pricing model (pay-per-use)

**Important**: The Playwright Python library itself is completely free. The Azure service is a separate commercial offering for enterprise teams needing cloud infrastructure.

## Commercial Use

Playwright is **fully approved for commercial use**:

### Business/Corporate Use
- Use in commercial software products
- Use for internal business automation
- Include in products you sell
- Use for client/customer projects
- No license fees or royalties required

### Restrictions
- Must include Apache 2.0 license text
- Cannot use Microsoft's trademarks
- Cannot hold Microsoft liable

### Examples of Permitted Use
- Web scraping for business intelligence
- Automated testing in commercial products
- Browser automation in SaaS applications
- Client project deliverables
- Internal corporate tools

## Comparison with Other Licenses

| License | Playwright (Apache 2.0) | MIT | GPL v3 |
|---------|------------------------|-----|--------|
| Commercial use | ✅ Yes | ✅ Yes | ✅ Yes |
| Modify code | ✅ Yes | ✅ Yes | ✅ Yes |
| Distribute | ✅ Yes | ✅ Yes | ✅ Yes |
| Sublicense | ✅ Yes | ✅ Yes | ❌ No |
| Patent grant | ✅ Yes | ❌ No | ✅ Yes |
| Private use | ✅ Yes | ✅ Yes | ✅ Yes |
| Must share changes | ❌ No | ❌ No | ✅ Yes |
| Can close source | ✅ Yes | ✅ Yes | ❌ No |

**Key difference**: Apache 2.0 includes explicit patent grants (protection against patent claims), while MIT does not. Apache 2.0 also requires change documentation.

## Dependencies and Third-Party Licenses

Playwright may include or depend on other open-source libraries, each with their own licenses. Check the Playwright repository for a complete list of dependencies.

Common dependency licenses:
- Most dependencies are also permissively licensed (MIT, BSD, Apache)
- Browser binaries (Chromium, Firefox, WebKit) have their own licenses
- Using Playwright does not impose additional license obligations beyond Apache 2.0

## License Compliance

### For Personal Projects
Simply use Playwright - no action required for personal, non-distributed projects.

### For Open Source Projects
Include the Apache 2.0 license text in your repository:

```
# In your README or LICENSE file
This project uses Playwright, licensed under the Apache License 2.0.
See: https://github.com/microsoft/playwright-python/blob/main/LICENSE
```

### For Commercial/Proprietary Software
1. Include Apache 2.0 license text (usually in a NOTICES or LICENSES file)
2. Retain copyright notices from Playwright
3. Document any modifications made to Playwright code (if applicable)
4. No need to open-source your code

**Example NOTICES file:**
```
This software includes Playwright, licensed under Apache License 2.0.
Copyright (c) Microsoft Corporation.
See full license: https://github.com/microsoft/playwright-python/blob/main/LICENSE
```

## Trademark Use

- The name "Playwright" and Microsoft trademarks cannot be used without permission
- You can say "powered by Playwright" or "uses Playwright" for attribution
- Cannot imply official endorsement by Microsoft

## Warranty and Liability

### No Warranty
Playwright is provided "AS IS" without any warranty:
- No guarantee of functionality
- No guarantee of fitness for purpose
- No guarantee of error-free operation
- Use at your own risk

### No Liability
Microsoft and contributors are not liable for:
- Damages from using Playwright
- Business losses
- Data loss
- Indirect or consequential damages

**This is standard for open-source software.**

## Support and Maintenance

### Community Support (Free)
- GitHub issues and discussions
- Stack Overflow questions
- Community forums and Discord

### Commercial Support (Paid)
- Microsoft may offer paid support contracts
- Third-party consultants available
- Not required to use the software

## Legal Summary

**Bottom Line**: Playwright is free, open-source software that you can use for any purpose, including commercial use, without paying any fees. You must include the license text and attribution when distributing software that includes Playwright.

## For the Bookmark Organizer Project

Playwright is perfectly suited for the bookmark_organizer project:

✅ **Free to use**: No cost for personal project
✅ **Commercial use allowed**: Could commercialize later if desired
✅ **No restrictions**: Use for web scraping without limitations
✅ **No attribution in UI**: Only needed in source code/documentation
✅ **Modify freely**: Can customize as needed
✅ **Private use**: No requirement to share code

### Recommended License Compliance

For bookmark_organizer:

1. **Add to pyproject.toml dependencies**: Already includes license info
2. **Optional**: Add to README.md under "Dependencies" section
3. **Optional**: Create LICENSES/ directory with Apache 2.0 text if distributing

Since bookmark_organizer is a personal tool (not distributed), minimal compliance is needed. Just include Playwright in requirements and you're good to go.

## Resources

### Official License Files
- **Full License Text**: https://github.com/microsoft/playwright/blob/main/LICENSE
- **Python Package License**: https://github.com/microsoft/playwright-python/blob/main/LICENSE

### License Information
- **Apache 2.0 Official**: https://www.apache.org/licenses/LICENSE-2.0
- **Apache 2.0 Summary**: https://choosealicense.com/licenses/apache-2.0/
- **OSI Approved**: https://opensource.org/licenses/Apache-2.0

### Microsoft Legal
- **Microsoft Open Source**: https://opensource.microsoft.com/
- **Microsoft OSS FAQ**: https://opensource.microsoft.com/faq/

## Frequently Asked Questions

### Q: Is Playwright really free?
**A**: Yes, completely free. The core library has no costs whatsoever.

### Q: Can I use it in my company's product?
**A**: Yes, Apache 2.0 explicitly allows commercial use.

### Q: Do I need to open-source my code?
**A**: No, Apache 2.0 does not require you to share your code.

### Q: Do I need to pay if I scrape millions of pages?
**A**: No, there are no usage-based fees for the library itself.

### Q: What's the difference from the paid Azure service?
**A**: The paid service is for cloud infrastructure and parallel testing at scale. The library is free.

### Q: Can Microsoft change the license later?
**A**: They could for future versions, but existing versions remain under Apache 2.0.

### Q: Do I need permission from Microsoft?
**A**: No, the license grants permission already.

### Q: Can I fork and modify Playwright?
**A**: Yes, you can fork and modify under Apache 2.0 terms.

## Conclusion

Playwright's Apache 2.0 license makes it one of the most developer-friendly open-source tools available. There are no costs, no restrictions on use cases, and minimal compliance requirements. It's ideal for both personal projects and commercial applications.

For the bookmark_organizer project, you can use Playwright freely without any legal concerns or costs.
