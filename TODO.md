# Bugs

These are issues that are preventing the library from working correctly.

* None

# Features

These are items that would provide additional features to RLTK users.

* Convert to Ruby 2.0 syntax.
  * Move to lazy enumerators
  * Keyword arguments
  * Nested methods
  * New lambda syntax
  * New hash syntax
  * Inject methods
* Update the documentation to use the @overloaded tag.
* Review and add to support for object finalization / memory cleanup
* Find home for unwrapped C binding functions
* Figure out what an AssemblyAnnotationWriter is and what it is used for.
* Add additional support for MCJIT.  This may require adding new bindings to LLVM 3.5. (http://llvm.org/docs/MCJITDesignAndImplementation.html)
  * Lazy compilation (http://blog.llvm.org/2013/07/using-mcjit-with-kaleidoscope-tutorial.html, http://blog.llvm.org/2013/07/kaleidoscope-performance-with-mcjit.html)
  * Object caching (http://blog.llvm.org/2013/08/object-caching-with-kaleidoscope.html)
* Support disassembly of objects
* Re-do the construction of binding objects from pointers
* Add C and Ruby bindings for additional atomic instructions

# Crazy Ideas

These are items that will require a significant amount of work to investigate their practicality and utility, let alone implement them.

* None
