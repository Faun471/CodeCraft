# Java Hello World Program
Java is one of the most popular and widely used programming languages and platforms. Java is fast, reliable, and secure. Java is used in every nook and corner from desktop to web applications, scientific supercomputers to gaming consoles, cell phones to the Internet. In this article, we will learn how to write a simple Java Program.

## Steps to Implement Java Program

Implementation of a Java application program involves the following step. They include:

1.  Creating the program
2.  Compiling the program
3.  Running the program

### 1. Creating Programs in Java

We can create a program using Text Editor (Notepad) or IDE (NetBeans)

```java
class Test
{
    public static void main(String []args)
    {
        System.out.println("My First Java Program.");
    }
};

```
### 2. Compiling the Program in Java

To compile the program, we must run the Java compiler (javac), with the name of the source file on the “command prompt” like as follows

If everything is OK, the “javac” compiler creates a file called “Test.class” containing the byte code of the program.

### 3. Running the Program in Java

We need to use the Java Interpreter to run a program. Java is easy to learn, and its syntax is simple and easy to understand. It is based on C++ (so easier for programmers who know C++).

The process of Java programming can be simplified in three steps:

-   Create the program by typing it into a text editor and saving it to a file – HelloWorld.java.
-   Compile it by typing “javac HelloWorld.java” in the terminal window.
-   Execute (or run) it by typing “java HelloWorld” in the terminal window.


<next page>

## Java Hello World

The below-given program is the most simple program of Java printing “Hello World” to the screen. Let us try to understand every bit of code step by step.

```java
// This is a simple Java program. 
// FileName : "HelloWorld.java". 

class HelloWorld { 
	// Your program begins with a call to main(). 
	// Prints "Hello, World" to the terminal window. 
	public static void main(String args[]) 
	{ 
		System.out.println("Hello World!"); 
	} 
}

```
**Output**
```bat
Hello World!
```
The complexity of the above method
```bat
Time Complexity: O(1)
Space Complexity: O(1)
```

<next page>

The “Hello World!” program consists of three primary components: the HelloWorld class definition, the main method, and source code comments. The following explanation will provide you with a basic understanding of the code:

### **1. Class Definition**

This line uses the keyword  **class** to declare that a new class is being defined.
```bat
class HelloWorld {
    //
    //Statements
}
```

### **2. HelloWorld**

It is an identifier that is the name of the class. The entire class definition, including all of its members, will be between the opening curly brace “**{**” and the closing curly brace “**}**“.

### **3. main Method**

In the Java programming language, every application must contain a main method. The main function(method) is the entry point of your Java application, and it’s mandatory in a Java program. whose signature in Java is:
```bat
public static void main(String[] args)
```