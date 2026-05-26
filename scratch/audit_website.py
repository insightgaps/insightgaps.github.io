import os
import re
import urllib.parse
from html.parser import HTMLParser

ROOT_DIR = r"c:\Users\Administrator\Desktop\insightgaps.github.io-main\insightgaps.github.io-main"

class AuditParser(HTMLParser):
    def __init__(self, current_file_path):
        super().__init__()
        self.current_file_path = current_file_path
        self.title_found = False
        self.title_content = ""
        self.in_title = False
        self.meta_desc = ""
        self.stylesheets = []
        self.links = []
        self.images = []
        self.text_content = []

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        if tag == 'title':
            self.in_title = True
            self.title_found = True
        elif tag == 'meta':
            if attrs_dict.get('name') == 'description':
                self.meta_desc = attrs_dict.get('content', '')
        elif tag == 'link':
            if attrs_dict.get('rel') == 'stylesheet':
                self.stylesheets.append(attrs_dict.get('href', ''))
        elif tag == 'a':
            self.links.append(attrs_dict.get('href', ''))
        elif tag == 'img':
            self.images.append(attrs_dict.get('src', ''))

    def handle_endtag(self, tag):
        if tag == 'title':
            self.in_title = False

    def handle_data(self, data):
        if self.in_title:
            self.title_content += data
        self.text_content.append(data)

def get_all_html_files():
    html_files = []
    for root, dirs, files in os.walk(ROOT_DIR):
        # Correctly check path parts to exclude specific directories
        parts = os.path.normpath(root).split(os.sep)
        if any(part in ('.git', '.github', 'node_modules') for part in parts):
            continue
        for file in files:
            if file.endswith('.html'):
                html_files.append(os.path.join(root, file))
    return html_files

def check_path_exists(ref_path, current_file_path):
    parsed = urllib.parse.urlparse(ref_path)
    if parsed.scheme or parsed.netloc:
        return True # External
    
    path = parsed.path
    if not path:
        return True # Anchor
    
    # Clean up leading slash
    if path.startswith('/'):
        target_path = os.path.join(ROOT_DIR, path.lstrip('/'))
    else:
        target_path = os.path.join(os.path.dirname(current_file_path), path)
        
    target_path = os.path.normpath(target_path)
    
    if os.path.exists(target_path):
        return True
    
    if os.path.isdir(target_path) and os.path.exists(os.path.join(target_path, 'index.html')):
        return True
        
    if not os.path.splitext(target_path)[1]:
        if os.path.exists(target_path + '.html'):
            return True
            
    return False

def audit_website():
    html_files = get_all_html_files()
    print(f"Auditing {len(html_files)} HTML files...\n")
    
    issues = {}
    
    for file_path in html_files:
        rel_path = os.path.relpath(file_path, ROOT_DIR)
        issues[rel_path] = []
        
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            
        parser = AuditParser(file_path)
        parser.feed(content)
        
        # 1. Check title tag
        if not parser.title_found or not parser.title_content.strip():
            issues[rel_path].append("Missing or empty <title> tag")
            
        # 2. Check meta description
        if not parser.meta_desc.strip():
            issues[rel_path].append("Missing or empty <meta name=\"description\"> tag")
            
        # 3. Check for placeholder patterns like ?? or TODO or SLOT:
        # Search lines for ?? or TODO not in comments
        lines = content.split('\n')
        for idx, line in enumerate(lines, 1):
            stripped = line.strip()
            # Ignore comments
            if stripped.startswith('<!--') or stripped.endswith('-->'):
                continue
            if '??' in line:
                issues[rel_path].append(f"Line {idx}: Contains possible placeholder '??' -> \"{stripped[:60]}\"")
            if 'TODO' in line:
                issues[rel_path].append(f"Line {idx}: Contains 'TODO' -> \"{stripped[:60]}\"")
            if 'SLOT:' in line:
                issues[rel_path].append(f"Line {idx}: Contains 'SLOT:' -> \"{stripped[:60]}\"")
            
        # 4. Check all links (<a href="...">)
        for href in parser.links:
            if not href:
                continue
            if href.startswith(('javascript:', 'mailto:', 'tel:', '#')):
                continue
            clean_href = href.split('?')[0].split('#')[0]
            if not check_path_exists(clean_href, file_path):
                issues[rel_path].append(f"Broken link: {href}")
                
        # 5. Check all images (<img src="...">)
        for src in parser.images:
            if not src:
                continue
            clean_src = src.split('?')[0].split('#')[0]
            if not check_path_exists(clean_src, file_path):
                issues[rel_path].append(f"Broken image source: {src}")
                
        # 6. Check that style.css is imported
        if not any('style.css' in s for s in parser.stylesheets if s):
            issues[rel_path].append(f"Missing stylesheet style.css. Found: {parser.stylesheets}")

    # Print summary of issues
    total_issues = 0
    for file, file_issues in issues.items():
        if file_issues:
            print(f"[{file}]")
            for issue in file_issues:
                print(f"  - {issue}")
                total_issues += 1
            print()
            
    print(f"Audit completed with {total_issues} issues found.")

if __name__ == '__main__':
    audit_website()
