# Welcome to the Ruby Code Generation Toolkit

RCGTK is a collection of classes and methods designed to help compiler designers generate code in straightforward manner.  This toolkit provides [Low Level Virtual Machine](http://llvm.org) (LLVM) bindings and helper classes.

## Why Use RCGTK

Here are some reasons to use RCGTK to generate LLVM IR and native object files:

* **LLVM Bindings** - RCGTK provides wrappers for most of the C LLVM bindings.

* **The Contractor** - LLVM's method of building instructions is a bit cumbersome, and is very imperative in style.  RCGTK provides the Contractor class to make things easier.

* **Documentation** - We have it!

* **I Eat My Own Dog Food** - I'm using RCGTK for my own projects so if there is a bug I'll most likely be the first one to know.

## RCGTK Version Numbers

The first two parts of the RCGTK version number correspond to the version of LLVM that the library supports.  Therefore RCGTK 3.4.* requires a LLVM 3.4 shared library.  The last number in a RCGTK version refers to the bug release number of the RCGTK library.  The last number of the version will only be incremented when RCGTK adds new bindings or fixes bugs in existing bindings.

## Code Generation

RCGTK supports the generation of native code and LLVM IR, as well as JIT compilation and execution.  This module is built on top of bindings to [LLVM](http://llvm.org) and provides much, though not all, of the functionality of the LLVM libraries.

## Acknowledgments and Discussion

Before we get started with the details, I would like to thank [Jeremy Voorhis](https://github.com/jvoorhis/).  The bindings present in RCGTK are really a fork of the great work that he did on [ruby-llvm](https://github.com/jvoorhis/ruby-llvm).

Why did I fork ruby-llvm, and why might you want to use the RCGTK bindings over ruby-llvm?  There are a couple of reasons:

* **Cleaner Codebase** - The RCGTK bindings present a cleaner interface to the LLVM library by conforming to more standard Ruby programming practices, providing better abstractions and cleaner inheritance hierarchies, overloading constructors and other methods properly, and performing type checking on objects to better aid in debugging.
* **Documentation** - RCGTK's bindings provide better documentation.
* **Completeness** - The RCGTK bindings provide several features that are missing from the ruby-llvm project.  These include the ability to initialize LLVM for architectures besides x86 (RCGTK supports all architectures supported by LLVM), the presence of all of LLVM's optimization passes, the ability to print the LLVM IR representation of modules and values to files and load modules *from* files, easy initialization of native architectures, initialization for ASM printers and parsers, and compiling modules to object files.
* **Ease of Use** - Several features have been added to make generating code easier such as automatic management of memory resources used by LLVM.
* **Speed** - The RCGTK bindings are ever so slightly faster due to avoiding unnecessary FFI calls.

Before you dive into generating code, here are some resources you might want to look over to build up some background knowledge on how LLVM works:

* [Static Single Assignment Form](http://en.wikipedia.org/wiki/Static_single_assignment_form)
* [LLVM Intermediate Representation](http://llvm.org/docs/LangRef.html)

## LLVM

Since RCGTK's code generation functionality is built on top of LLVM the first step in generating code is to inform LLVM of the target architecture.  This is accomplished via the {RCGTK::LLVM.init} method, which is used like this: `RCGTK::LLVM.init(:PPC)`.  The {RCGTK::Bindings::ARCHS} constant provides a list of supported architectures.  This call must appear before any other calls to the RCGTK module.

If you would like to see what version of LLVM is targeted by your version of RCGTK you can either call the {RCGTK::LLVM.version} method or looking at the {RCGTK::LLVM\_TARGET\_VERSION} constant.

## Modules

Modules are one of the core building blocks of the code generation module.  Functions, constants, and global variables all exist inside a particular module and, if you use the JIT compiler, a module provides the context for your executing code.  New modules can be created using the {RCGTK::Module#initialize RCGTK::Module.new} method.  While this method is overloaded you, as a library user, will always pass it a string as its first argument.  This allows you to name your modules for easier debugging later.

Once you have created you can serialize the code inside of it into *bitcode* via the {RCGTK::Module#write\_bitcode} method.  This allows you to save partially generated code and then use it later.  To load a module from *bitcode* you use the {RCGTK::Module.read\_bitcode} method.

## Types

Types are an important part of generating code using LLVM.  Functions, operations, and other constructs use types to make sure that the generated code is sane.  All types in RCGTK are subclasses of the {RCGTK::Type} class, and have class names that end in "Type".  Types can be grouped into to categories: fundamental and composite.

Fundamental types are those like {RCGTK::Int32Type} and {RCGTK::FloatType} that don't take any arguments when they are created.  Indeed, these types are represented using a Singleton class, and so the `new` method is disabled.  Instead you can use the `instance` method to get an instantiated type, or simply pass in the class itself whenever you need to reference the type.  In this last case, the method you pass the class to will instantiate the type for you.

Composite types are constructed from other types.  These include the {RCGTK::ArrayType}, {RCGTK::FunctionType}, and other classes.  These types you must instantiate directly before they can be used, and you may not simply pass the type class as the type argument to functions inside the RCGTK module.

For convenience, the native integer type of the host platform is made available via {RCGTK::NativeIntType}.

## Values

The {RCGTK::Value} class is the common ancestor of many classes inside the RCGTK module.  The main way in which you, the library user, will interact with them is when creating constant values.  Here is a list of some of value classes you might use:

* {RCGTK::Int1}
* {RCGTK::Int8}
* {RCGTK::Int16}
* {RCGTK::Int32}
* {RCGTK::Int64}
* {RCGTK::Float}
* {RCGTK::Double}
* {RCGTK::ConstantArray}
* {RCGTK::ConstantStruct}

Again, for convenience, the native integer class of the host platform is made available via {RCGTK::NativeInt}.

## Functions

Functions in LLVM are much like C functions; they have a return type, argument types, and a body.  Functions may be created in several ways, though they all require a module in which to place the function.

The first way to create functions is via a module's function collection:

```Ruby
mod.functions.add('my function', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])
```

Here we have defined a function named 'my function' in the `mod` module.  It takes two native integers as arguments and returns a native integer.  It is also possible to define the type of a function ahead of time and pass it to this method:

```Ruby
type = RCGTK::FunctionType.new(RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])
mod.functions.add('my function', type)
```

Functions may also be created directly via the {RCGTK::Function#initialize RCGTK::Function.new} method, though a reference to a module is still necessary:

```Ruby
mod = Module.new('my module')
fun = Function.new(mod, 'my function', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])
```

or

```Ruby
mod  = Module.new('my module')
type = RCGTK::FunctionType.new(RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])
fun  = Function.new(mod, 'my function', type)
```

Lastly, whenever you use one of these methods to create a function you may give it a block to be executed inside the context of the function object.  This allows for easier building of functions:

```Ruby
mod.functions.add('my function', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType]) do
  bb = blocks.append('entry)'
  ...
end
```

## Basic Blocks

Once a function has been added to a module you will need to add {RCGTK::BasicBlock BasicBlocks} to the function.  This can be done easily:

```Ruby
bb = fun.blocks.append('entry')
```

We now have a basic block that we can use to add instructions to our function and get it to actually do something.  You can also instantiate basic blocks directly:

```Ruby
bb = RCGTK::BasicBlock.new(fun, 'entry')
```

## The Builder

Now that you have a basic block you need to add instructions to it.  This is accomplished using a {RCGTK::Builder builder}, either directly or indirectly.

To add instructions using a builder directly (this is most similar to how it is done using C/C++) you create the builder, position it where you want to add instructions, and then build them:

```Ruby
fun = mod.functions.add('add', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])
bb  = fun.blocks.append('entry')

builder = RCGTK::Builder.new

builder.position_at_end(bb)

# Generate an add instruction.
inst0 = builder.add(fun.params[0], fun.params[1])

# Generate a return instruction.
builder.ret(inst0)
```

You can get rid of some of those references to the builder by using the {RCGTK::Builder#build} method:

```Ruby
fun = mod.functions.add('add', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])
bb  = fun.blocks.append('entry')

builder = RCGTK::Builder.new

builder.build(bb) do
  ret add(fun.params[0], fun.params[1])
end
```

To get rid of more code:

```Ruby
fun = mod.functions.add('add', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])
bb  = fun.blocks.append('entry')

RCGTK::Builder.new(bb) do
  ret add(fun.params[0], fun.params[1])
end
```

or

```Ruby
fun = mod.functions.add('add', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])
fun.blocks.append('entry') do
  ret add(fun.params[0], fun.params[1])
end
```

or even

```Ruby
mod.functions.add('add', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType]) do
  blocks.append('entry') do |fun|
    ret add(fun.params[0], fun.params[1])
  end
end
```

In the last two examples a new builder object is created for the block.  It is possible to specify the builder to be used:

```Ruby
builder = RCGTK::Builder.new

mod.functions.add('add', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType]) do
  blocks.append('entry', builder) do |fun|
    ret add(fun.params[0], fun.params[1])
  end
end
```

For an example of where this is useful, see the Kazoo tutorial.

## The Contractor

An alternative to using the {RCGTK::Builder} class is to use the {RCGTK::Contractor} class, which is a subclass of the Builder and includes the Filigree::Visitor module. (Get it? It's a visiting builder!)  By subclassing the Contractor you can define blocks of code for handling various types of AST nodes and leave the selection of the correct code up to the {RCGTK::Contractor#visit} method.  In addition, the `:at` and `:rcb` options to the *visit* method make it much easier to manage the positioning of the Builder.

Here we can see how easy it is to define a block that builds the instructions for binary operations:

```Ruby
on Binary do |node|
  left  = visit node.left
  right = visit node.right

  case node
    when Add then fadd(left, right, 'addtmp')
    when Sub then fsub(left, right, 'subtmp')
    when Mul then fmul(left, right, 'multmp')
    when Div then fdiv(left, right, 'divtmp')
    when LT  then ui2fp(fcmp(:ult, left, right, 'cmptmp'), RCGTK::DoubleType, 'booltmp')
  end
end
```

AST nodes whos translation requires the generation of control flow will require the creation of new BasicBlocks and the repositioning of the builder.  This can be easily managed:

```Ruby
on If do |node|
  cond_val = visit node.cond
  fcmp :one, cond_val, ZERO, 'ifcond'

  start_bb = current_block
  fun      = start_bb.parent

  then_bb               = fun.blocks.append('then')
  then_val, new_then_bb = visit node.then, at: then_bb, rcb: true

  else_bb               = fun.blocks.append('else')
  else_val, new_else_bb = visit node.else, at: else_bb, rcb: true

  merge_bb = fun.blocks.append('merge', self)
  phi_inst = build(merge_bb) { phi RCGTK::DoubleType, {new_then_bb => then_val, new_else_bb => else_val}, 'iftmp' }

  build(start_bb) { cond cond_val, then_bb, else_bb }

  build(new_then_bb) { br merge_bb }
  build(new_else_bb) { br merge_bb }

  returning(phi_inst) { target merge_bb }
end
```

More extensive examples of how to use the Contractor class can be found in the Kazoo tutorial chapters.

## Execution Engines

Once you have generated your code you may want to run it.  RCGTK provides bindings to both the LLVM interpreter and JIT compiler to help you do just that.  Creating a JIT compiler is pretty simple.

```Ruby
mod = RCGTK::Module.new('my module')
jit = RCGTK::JITCompiler(mod)

mod.functions.add('add', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType]) do
  blocks.append('entry', nil, nil, self) do |fun|
    ret add(fun.params[0], fun.params[1])
  end
end
```

Now you can run your 'add' function like this:

```Ruby
jit.run(fun, 1, 2)
```

The result will be a {RCGTK::GenericValue} object, and you will want to use its {RCGTK::GenericValue#to\_i #to\_i} and {RCGTK::GenericValue#to\_f #to\_f} methods to get the Ruby value result.

## Tutorial

There are several examples of the use of the RLTK and RCGTK libraries.  They are located in a new project that will be linked here shortly.

## Contributing

If you are interested in contributing to RCGTK there are many aspects of the library that you can work on.  A detailed TODO list can be found in the TODO file.

## News

This project is a fork from RLTK to provide just the code generation capabilities.  This will allow developers to manage their RLTK and RCGTK/LLVM versions independently.
