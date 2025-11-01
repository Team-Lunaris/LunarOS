#!/usr/bin/bash
set -eoux pipefail

###############################################################################
# Configure VS Code User Settings
###############################################################################
# Sets up default VS Code settings for all users via /etc/skel
###############################################################################

echo "::group:: Configure VS Code Settings"

# Create VS Code config directory in skel
mkdir -p /etc/skel/.config/VSCode/User

# Create settings.json with user configuration
cat > /etc/skel/.config/VSCode/User/settings.json << 'EOF'
{
  // Window and UI Configuration
  "window.controlsStyle": "custom",
  "window.titleBarStyle": "custom",
  "window.commandCenter": true,
  "window.menuBarVisibility": "compact",
  "window.customTitleBarVisibility": "auto",
  "window.systemColorTheme": "dark",

  // Git and Version Control
  "git.autofetch": true,
  "git.confirmSync": false,
  "explorer.confirmDragAndDrop": false,

  // AI and Language Settings
  "AI.chatLanguage": "English",

  // Telemetry and Privacy
  "telemetry.telemetryLevel": "off",
  "redhat.telemetry.enabled": false,

  // File Handling
  "files.autoSave": "onWindowChange",
  "typescript.updateImportsOnFileMove.enabled": "always",

  // Editor Configuration
  "editor.fontSize": 14,
  "editor.fontFamily": "'Segoe UI Variable', 'JetBrains Mono', 'Fira Code', Consolas, 'Courier New', monospace",
  "editor.fontLigatures": true,
  "editor.formatOnPaste": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.semanticHighlighting.enabled": true,
  "editor.inlineSuggest.suppressSuggestions": true,
  "editor.minimap.enabled": false,
  "editor.minimap.renderCharacters": false,
  "editor.minimap.showSlider": "always",
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.smoothScrolling": true,

  // Diff Editor
  "diffEditor.codeLens": true,
  "diffEditor.ignoreTrimWhitespace": false,

  // Language-Specific Formatters
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[mdx]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },

  // TypeScript Configuration
  "typescript.tsserver.web.projectWideIntellisense.suppressSemanticErrors": true,

  // Workbench Appearance
  "workbench.colorTheme": "Default Dark+",
  "workbench.iconTheme": "material-icon-theme",
  "workbench.productIconTheme": "fluent-icons",
  "workbench.editor.showTabs": "multiple",
  "workbench.editor.tabSizing": "fit",
  "workbench.startupEditor": "welcomePage",

  // Terminal Configuration
  "terminal.integrated.defaultProfile.windows": "Git Bash",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.fontFamily": "'JetBrains Mono', 'Cascadia Code', Consolas",
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.smoothScrolling": true,

  // FLUENT UI EXTENSION SETTINGS
  "fluentui.compact": false,
  "fluentui.enableWallpaper": false,
  "fluentui.wallpaperPath": "C:\\Windows\\Web\\Wallpaper\\Windows\\img0.jpg",
  "fluentui.accent": "#6b8e6b",
  "fluentui.darkBackground": "#000000",
  "fluentui.lightBackground": "#ffffff",

  // Enhanced Color Customizations for Ultra Dark Theme
  "workbench.colorCustomizations": {
    // Main backgrounds
    "editor.background": "#000000",
    "activityBar.background": "#000000",
    "sideBar.background": "#000000",
    "panel.background": "#000000",
    "statusBar.background": "#000000",
    "titleBar.activeBackground": "#000000",
    "titleBar.inactiveBackground": "#000000",
    "tab.inactiveBackground": "#000000",
    "editorGroupHeader.tabsBackground": "#000000",
    "terminal.background": "#000000",
    "menu.background": "#000000",
    "welcomePage.background": "#000000",

    // Secondary backgrounds
    "tab.activeBackground": "#0f0f0f",
    "sideBarSectionHeader.background": "#0f0f0f",
    "input.background": "#0f0f0f",
    "dropdown.background": "#0f0f0f",
    "editorWidget.background": "#0f0f0f",
    "quickInput.background": "#0f0f0f",
    "editorHoverWidget.background": "#0f0f0f",
    "editorSuggestWidget.background": "#0f0f0f",

    // Borders
    "panel.border": "#111111",
    "sideBar.border": "#111111",
    "editorGroup.border": "#111111",
    "input.border": "#111111",
    "dropdown.border": "#111111",
    "peekView.border": "#111111",

    // Accent colors
    "activityBarBadge.background": "#6b8e6b",
    "activityBarBadge.foreground": "#000000",
    "button.background": "#6b8e6b",
    "button.foreground": "#ffffff",
    "button.hoverBackground": "#7a9d7a",
    "progressBar.background": "#6b8e6b",
    "focusBorder": "#6b8e6b",
    "editorCursor.foreground": "#6b8e6b",
    "editorLineNumber.activeForeground": "#6b8e6b",
    "tab.activeBorder": "#6b8e6b",
    "panelTitle.activeBorder": "#6b8e6b",
    "list.highlightForeground": "#6b8e6b",
    "textLink.foreground": "#6b8e6b",
    "inputOption.activeBorder": "#6b8e6b",
    "editorInfo.foreground": "#6b8e6b",
    "editorLink.activeForeground": "#6b8e6b",

    // Selection and highlights
    "editor.selectionBackground": "#6b8e6b60",
    "editor.selectionForeground": "#ffffff",
    "editor.inactiveSelectionBackground": "#6b8e6b30",
    "editor.selectionHighlightBackground": "#6b8e6b40",
    "editor.wordHighlightBackground": "#6b8e6b30",
    "editor.wordHighlightStrongBackground": "#6b8e6b50",
    "editor.findMatchBackground": "#6b8e6b70",
    "editor.findMatchHighlightBackground": "#6b8e6b40",
    "list.activeSelectionBackground": "#1a1a1a",
    "list.hoverBackground": "#0f0f0f",
    "list.focusBackground": "#1a1a1a",
    "list.inactiveSelectionBackground": "#0f0f0f",

    // Text colors
    "editor.foreground": "#c0c0c0",
    "sideBar.foreground": "#c0c0c0",
    "activityBar.foreground": "#6b8e6b",
    "activityBar.inactiveForeground": "#505050",
    "statusBar.foreground": "#c0c0c0",
    "titleBar.activeForeground": "#c0c0c0",
    "titleBar.inactiveForeground": "#808080",
    "tab.activeForeground": "#c0c0c0",
    "tab.inactiveForeground": "#808080",
    "editorLineNumber.foreground": "#333333",
    "sideBarSectionHeader.foreground": "#6b8e6b",
    "panelTitle.activeForeground": "#c0c0c0",
    "panelTitle.inactiveForeground": "#808080",

    // Scrollbars
    "scrollbarSlider.background": "#0f0f0f60",
    "scrollbarSlider.hoverBackground": "#1a1a1a60",
    "scrollbarSlider.activeBackground": "#6b8e6b60",

    // Git decorations
    "gitDecoration.modifiedResourceForeground": "#6b8e6b",
    "gitDecoration.addedResourceForeground": "#6b8e6b",
    "gitDecoration.untrackedResourceForeground": "#808080",
    "gitDecoration.deletedResourceForeground": "#8b5a5a",
    "gitDecoration.conflictingResourceForeground": "#8b5a5a",
    "gitDecoration.ignoredResourceForeground": "#404040",

    // Terminal colors
    "terminal.foreground": "#c0c0c0",
    "terminal.ansiBlack": "#000000",
    "terminal.ansiBrightBlack": "#404040",
    "terminal.ansiWhite": "#c0c0c0",
    "terminal.ansiBrightWhite": "#ffffff",
    "terminal.ansiGreen": "#6b8e6b",
    "terminal.ansiBrightGreen": "#7a9d7a",

    // Editor gutter
    "editorGutter.background": "#000000",
    "editorGutter.modifiedBackground": "#6b8e6b",
    "editorGutter.addedBackground": "#6b8e6b",
    "editorGutter.deletedBackground": "#8b5a5a",

    // Minimap
    "minimap.background": "#000000",
    "minimapSlider.background": "#1a1a1a40",
    "minimapSlider.hoverBackground": "#1a1a1a60",
    "minimapSlider.activeBackground": "#1a1a1a80",

    // Status bar items
    "statusBarItem.activeBackground": "#1a1a1a",
    "statusBarItem.hoverBackground": "#1a1a1a",
    "statusBarItem.prominentBackground": "#1a1a1a",
    "statusBarItem.prominentHoverBackground": "#2a2a2a",

    // Breadcrumbs
    "breadcrumb.background": "#000000",
    "breadcrumb.foreground": "#808080",
    "breadcrumb.focusForeground": "#c0c0c0",
    "breadcrumb.activeSelectionForeground": "#6b8e6b",

    // Tabs
    "tab.activeBorder": "#6b8e6b",
    "tab.activeBorderTop": "#6b8e6b",
    "tab.unfocusedActiveBorder": "#404040",
    "tab.unfocusedActiveBorderTop": "#404040"
  },

  // Additional UI Enhancements
  "breadcrumbs.enabled": true,
  "breadcrumbs.filePath": "on",
  "breadcrumbs.symbolPath": "on",

  // Search and Quick Open
  "search.useGlobalIgnoreFiles": true,
  "search.smartCase": true,
  "search.showLineNumbers": true,
  "extensions.autoCheckUpdates": false,

  // Debug Configuration
  "debug.inlineValues": "on",
  "debug.toolBarLocation": "floating",

  // Zen Mode
  "zenMode.hideActivityBar": false,
  "zenMode.hideStatusBar": false,
  "zenMode.centerLayout": false,

  // Security
  "security.workspace.trust.untrustedFiles": "prompt",
  "security.workspace.trust.banner": "always",

  // Performance
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/node_modules/*/**": true,
    "**/.hg/store/**": true
  },

  // Misc
  "chatgpt.config": {},
  "git.replaceTagsWhenPull": true
}
EOF

echo "VS Code settings configured"

echo "::endgroup::"
