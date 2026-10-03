Quick cheat sheet for LazyVim keybinds
### Core Navigation
|               |                               |
| ------------- | ----------------------------- |
| **\<C-f>**    | Forward (Page down)           |
| **\<C-d>**    | Move down (Half a page)       |
| **\<C-b>**    | Backward (Page up)            |
| **\<C-u>**    | Move up (Half a page)         |
| **\<C-o>**    | Jump back                     |
| **\<C-i>**    | Jump forward                  |
| **gg**        | Go to first line              |
| **Shift-G**   | Go to last line               |
| **:10, 10gg** | Jump to line# 10              |
| **10j**       | (Relative) Jump down 10 lines |
| **10k**       | (Relative) Jump up 10 lines   |
| **J**         | Join lines                    |

### UI/UX
|                 |                           |
| --------------- | ------------------------- |
| **\<leader>uC** | Colorscheme with preview  |
| **\<leader>uD** | Enable code block dimming |
| **\<leader>ul** | Toggle line number        |
| **\<leader>uL** | Toggle relative number    |
| **\<leader>uw** | Toggle word wrap          |
| **\<C-/>**      | Toggle Terminal window    |
| **:Neotree**    | Neotree file explorer     |

### Buffer Management
|                   |                      |
| ----------------- | -------------------- |
| **\<leader>fb**   | List open buffers    |
| **\<Shift>l/h**   | Next/Prev buffer     |
| **]b** or **[b**  | Next/Prev buffer     |
| **\<leader>bd**   | Close current buffer |
| **\<C-w>v**       | Split vertical       |
| **\<C-w>s**       | Split horizontal     |
| **\<C-w>h/j/k/l** | Navigate splits      |

### Text Objects
|         |                           |
| ------- | ------------------------- |
| **viw** | Select inner word         |
| **vi"** | Select inner quotes       |
| **vi{** | Select inner curly braces |
| **vip** | Select inner paragraph    |
| **va[** | Select around [] braces   |
| **dap** | Delete around paragraph   |

### Code Folding
|                  |                               |
| ---------------- | ----------------------------- |
| **zR** or **zi** | Open all folds                |
| **zM**           | Close all folds               |
| **za**           | Toggle fold                   |
| **zA**           | Toggle all folds under cursor |
| **zc**           | Close fold                    |
| **zo**           | Open fold                     |
| **zO**           | Open all folds under cursor   |

### Marks & Bookmarks
|                   |                            |
| ----------------- | -------------------------- |
| **\<leader>sm**   | View all marks             |
| **m[a-z]**        | Set local mark             |
| **'[a-z]**        | Jump to mark               |
| **' '**           | Jump to last position      |
| **\`[a-z]**       | Jump to exact position     |
| **:delmarks a-z** | Del lowercase marks (a-z)  |
| **:delmarks ax**  | Del "a" and "x" marks      |
| **:delmarks!**    | Del marks (except A-Z,0-9) |

### Functions & Symbols (LSP)
|                  |                            |
| ---------------- | -------------------------- |
| **:LspInfo**     | Show attached LSP info     |
| **\<leader>cs**  | Document symbols           |
| **gr**           | Find all                   |
| **gd**           | Go to definition           |
| **gD**           | Go to declaration          |
| **gy**           | Goto Type definition       |
| **K**            | Show doscstring/type hints |
| **[[** or **]]** | Prev/Next                  |
 
### Diagnostics
|                |                       |
| -------------- | --------------------- |
| **]d**         | Next diagnostic       |
| **[d**         | Prev diagnostic       |
| **<leader>sd** | Document diagnostics  |
| **<leader>sD** | Workspace diagnostics |

### Code Actions
|                 |                |
| --------------- | -------------- |
| **\<leader>cr** | Rename symbols |
| **\<leader>cf** | Format code    |
| **\<leader>ca** | Code actions   |

### Indentation
|          |                             |
| -------- | --------------------------- |
| **>**    | Indent right                |
| **<**    | Indent left                 |
| **=**    | Auto-indent as per language |
| **=ip**  | Indent current paragraph    |
| **gg=G** | Auto-indent entire file     |

### Search

|                 |                          |
| --------------- | ------------------------ |
| **\<leader>sr** | Search and Replace       |
| **\<leader>fc** | Find Config files        |
| **\<leader>ff** | Find files (Root dir)    |
| **\<leader>/**  | Grep (Root dir)          |
| **\<leader>sG** | Grep (CWD)               |
| **\<leader>ss** | Symbol search            |
| **\<leader>sc** | Command history          |
| **\<leader>sw** | Search word under cursor |
| **\<leader>sk** | Search all keymaps       |
| **\<leader>st** | Search TODO\|WARNING     |

### Git (fzf-lua)
|                 |                         |
| --------------- | ----------------------- |
| **\<leader>gc** | Commit log texts search |
| **\<leader>gs** | Status (file search)    |
| **\<leader>ge** | Git explorer (Neotree)  |
| **\<leader>gf** | Current file history    |

### LazyGit

|                 |                        |
| --------------- | ---------------------- |
| **\<leader>gg** | Open LazyGit window    |
| **\<C-r>**      | Switch to recent repo  |
| **\<C-b>**      | Filter files by status |
| **p**           | Git pull               |
| **P**           | Git push               |
| **\<space>**    | Stage                  |
| **a**           | Stage all              |
| **c**           | Commit                 |
| **s**           | Stash                  |
| **z**           | Undo                   |
| **\<C-z>**      | Redo                   |
| **i**           | Add to .gitignore      |
| **q**           | Quit                   |