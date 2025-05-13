[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/bPoO8GTw)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=19516567&assignment_repo_type=AssignmentRepo)

# Developer Info
Name: Vanshi Mehta  
Roll Number: 22000937

# GenZ Lang Compiler
# Project Description
This project is a custom compiler for a fictional programming language called **GenZ Lang**, designed with Gen-Z-inspired syntax. The compiler is built using **Flex** (Lexical Analyzer) and **Bison** (Parser Generator), and it processes GenZ-styled code to generate **Three-Address Code (TAC)** for intermediate representation.

# Language Keywords
| Keyword      | Purpose                           |
|--------------|-----------------------------------|
| `wassup`     | Start of program                  |
| `rip`        | End of program                    |
| `drop`       | Declare or assign variable        |
| `spill`      | Print statement                   |
| `fr`         | If condition                      |
| `nah`        | Else block                        |
| `dead`       | End of if/else/loop/function      |
| `grind`      | For loop                          |
| `tea`        | Function declaration              |
| `slideIn`    | Function call                     |
| `#realtalk`  | Comment (ignored by compiler)     |

# Tools & Technologies Used
- Flex: For tokenizing the input source code (genz_flex.l)
- Bison: For parsing and generating intermediate code (genz_bison.y)
- GCC: To compile the generated C files
- Three-Address Code (TAC): As intermediate output

# Project Structure
| File Name            | Description                            |
|----------------------|----------------------------------------|
| `genz_flex.l`        | Flex file for lexical analysis         |
| `genz_bison.y`       | Bison file for syntax and TAC parsing  |
| `program.genz`       | Sample input GenZ Lang code            |
| `genz_bison.tab.h/c` | Bison generated headers and parser     |
| `lex.yy.c`           | Lex generated analyzer                 |
| `starwars_compiler.exe` | Compiled compiler binary            |
