---
sidebar_position: 2
---

# About

:::danger NOTICE
Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please create an issue on the GitHub repository.
:::

## What is Scrypt?
Scrypt is a lightweight Roblox development framework. Scrypt aims to be an easy-to-use framework to power your Roblox projects! It includes several feature to improve your workflow over vanilla Luau. Those include:
* Lazily loaded modules
* Built in networking
* Support for three types of modules (Services, Controllers, Shared modules)
* Built-in Utilities (Custom events and functions, roblox service access, and more)
* Easy Gui access

Scrypt is planned on being supported for many years to come and much more is planned to be added!

### Functional Programming

Scrypt also aims to promote functional programming. While the basic usage of Scrypt is not purely functional, its internals were built using strong functional foundations and encourages developers to use functional programming in their services and controllers as much as possible. Scrypt also includes a small bulit-in Utils library which contains some common pure functions:
* Filter
* Map
* Reduce

Functional programming is what is known as a programming paradigm. A paradigm controls the structure or 'style' of how code is written. Some common paradigms include: object-oriented, imperative, procedural, and of course, functional. The functional paradigm has a few main properties that define what it exactly is. If you want to go in depth on what these are, you can look further into it but the main pillars of functional programming are:
* Data is immutable
* Functions are pure
* Higher order and first class functions
* Reduced (or no) side effects

### Future Plans / Roadmap
Currently, there is no official roadmap for Scrypt. There are features that are being planned but the timeline on the implementation is not set. One of the main features that is planned is optimized network communication. As of version 0.0.52-alpha, there is no performance benefit to using the built-in networking systems vs just using remote events or remote functions. 

More coming soon!