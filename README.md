# worx
WORX programming language.

WORX is a forth-like language, currently in its early stages.

The stack in WORX at the moment is.... *Slow*... The strategy for faster programs at the current moment is to just avoid the stack entirely and use variables. This is being actively worked on.

# Examples
Examples can be found in the `examples` folder in the repository.

# Building
You need `dub` and a D compiler, these are built on my machine using `ldc2` but `gdc` and `dmd` work perfectly fine, although they produce much slower code for some reason.

You can build the project by running `dub build --build=release` in your terminal.
