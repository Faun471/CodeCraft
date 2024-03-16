# Java Basics Syntax

Java program is an object-oriented programming language, that means java is the collection of objects, and these objects communicate through method calls to each other to work together. Here is a brief discussion on the Classes and Objects, Methods, Instance variables, syntax, and semantics of Java.

## Basic Terminologies in Java

 1. **Class:** The class is a blueprint (plan) of the instance of a class (object). It can be defined as a logical template that share common properties and methods.
 2. **Object:** The object is an instance of a class. It is an entity that has behavior and state.
 3. **Method:** The behavior of an object is the method.
 4. **Instance variables:** Every object has its own unique set of instance variables. The state of an object is generally created by the values that are assigned to these instance variables.
 
<br>

Steps to compile and run a java program in a console:

```bat
javac CC.java
java CC
```
```java

import java.util.*;
public class CC {
	public static void main(String[] args)
	{
		System.out.println("CodeCraft");
	}
}

```
**Output**
```bat
CodeCraft
```

## Syntax

**Comments in Java**

There are three types of comments in Java.

  *Single-line Comment*
```bat
// System.out.println("This is a Single-line comment.");
```
  *Multi-line Comment*
```bat
/*
    System.out.println("This is the first line comment.");
    System.out.println("This is the second line comment.");
*/
```
  *Documentation Comment. Also called a **doc comment**.*
```bat
/** documentation */
```

<br>

**Source File Name**
The name of a source file should exactly match the public class name with the extension of .**java**. The name of the file can be a different name if it does not have any public class. Assume you have a public class **GFG**.
```bat
CC.java // valid syntax
_cc_.java // invalid syntax
```
<br>

**Case Sensitivity**
Java is a case-sensitive language, which means that the identifiers _**AB, Ab, aB**_,  and _**ab**_ are different in Java.
```bat
System.out.println("CodeCraft"); // valid syntax
_s_ystem.out.println("CodeCraft"); // invalid syntax because of the first letter of System keyword is always uppercase.
```
<br>

**Class Names**

 1. The first letter of the class should be in Uppercase (lowercase is allowed but discouraged).
 2. If several words are used to form the name of the class, each inner word’s first letter should be in Uppercase. Underscores are allowed, but not recommended. Also allowed are numbers and currency symbols, although the latter are also discouraged because they are used for a special purpose (for inner and anonymous classes).
```bat
class MyJavaProgram    // valid syntax
class 1Program         // invalid syntax
class My1Program       // valid syntax
class $Program         // valid syntax, but discouraged
class My$Program       // valid syntax, but discouraged (inner class Program inside the class My)
class myJavaProgram    // valid syntax, but discouraged
```
<br>

****public static void main(String [] args)****
The method main() is the main entry point into a Java program; this is where the processing starts. Also allowed is the signature **public static void main(String… args)**.

<br>

**Method Names**

 1. All the method names should start with a lowercase letter (uppercase is also allowed but lowercase is recommended).
 2. If several words are used to form the name of the method, then each first letter of the inner word should be in Uppercase. Underscores are allowed, but not recommended. Also allowed are digits and currency symbols.
```bat
public void employeeRecords() // valid syntax
public void EmployeeRecords() // valid syntax, but discouraged
``` 

<br>

**Identifiers in java**
Identifiers are the names of local variables, instance and class variables, and labels, but also the names for classes, packages, modules and methods. All Unicode characters are valid, not just the ASCII subset.

 - All identifiers can begin with a letter, a currency symbol or an underscore (**_**). According to the convention, a letter should be lower case for variables.
 - The first character of identifiers can be followed by any combination of letters, digits, currency symbols and the underscore. The underscore is not recommended for the names of variables. Constants (static final attributes and enums) should be in all Uppercase letters.
 - Most importantly identifiers are case-sensitive.
 - A keyword cannot be used as an identifier since it is a reserved word and has some special meaning.
```bat
Legal identifiers: MinNumber, total, ak74, hello_world, $amount, _under_value
Illegal identifiers: 74ak, -amount
``` 
<br>

**White Spaces in Java**
A line containing only white spaces, possibly with the comment, is known as a blank line, and the Java compiler totally ignores it.
<br>
**Access Modifiers**
*These modifiers control the scope of class and methods.*
-   **Access Modifiers:**  default, public, protected, private.
-    **Non-access Modifiers:**  final, abstract, static, transient, synchronized, volatile, native.
<br>

**Understanding Access Modifiers**
| Access Modifier | Within Class | Within Package | Outside Package by subclass only | Outside Package |
|------------------|--------------|-----------------|----------------------------------|------------------|
| Private          | Yes          | No              | No                               | No               |
| Default          | Yes          | Yes             | No                               | No               |
| Protected        | Yes          | Yes             | Yes                              | No               |
| Public           | Yes          | Yes             | Yes                              | Yes              |

<br>

**Java Keywords**
Keywords or Reserved words are the words in a language that are used for some internal process or represent some predefined actions. These words are therefore not allowed to use as variable names or objects.
| abstract | assert | boolean | break |
| --- | --- | --- | --- |
| byte | case | catch | char |
| class | const | continue | default |
| do | double | else | enum |
| extends | final | finally | float |
| for | goto | if | implements |
| import | instanceof | int | interface |
| long | native | new | package |
| private | protected | public | return |
| short | static | strictfp | super |
| switch | synchronized | this | throw |
| throws | transient | try | void |
| volatile | while | | |
