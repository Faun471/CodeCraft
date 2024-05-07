![Java Logo](https://logos-download.com/wp-content/uploads/2016/10/Java_logo_icon.png)

# Introduction to Java

---

Java is a versatile and widely used programming language that has been a cornerstone of software development for decades. Developed by Sun Microsystems (now owned by Oracle Corporation), Java was released in 1995 and quickly gained popularity due to its platform independence, object-oriented features, and robustness.

## Key Features

### 1. **Platform Independence:**

Java is known for its "write once, run anywhere" philosophy. This is made possible by the Java Virtual Machine (JVM), which allows Java programs to run on any device that has a compatible JVM installed.

### 2. **Object-Oriented:**

Java follows the object-oriented programming (OOP) paradigm, encouraging the use of classes and objects. This approach promotes code organization, reusability, and modularity.

### 3. **Robust and Secure:**

Java's strict compile-time and runtime checks contribute to its robustness. Additionally, it has built-in security features, such as the Java Security Manager, to create a secure execution environment.

### 4. **Multithreading:**

Java supports multithreading, allowing developers to create concurrent and parallel applications. This is crucial for enhancing performance in applications that require simultaneous execution of tasks.

### 5. **Rich Standard Library:**

Java comes with a comprehensive standard library that provides a wide range of pre-built classes and functions, simplifying common programming tasks.

<next page>

## Getting Started

To start programming in Java, you'll need to set up the Java Development Kit (JDK) on your machine. The JDK includes the Java Compiler (`javac`), the Java Virtual Machine (`java`), and other essential tools.

### Installing JDK

1. **Visit the official Oracle website:**
Download the latest version of the JDK from [Oracle's Java SE Downloads page](https://www.oracle.com/java/technologies/javase-downloads.html).
2. **Follow installation instructions:**
Install the JDK by following the instructions provided for your specific operating system (Windows, macOS, or Linux).

<next page>

### Writing Your First Java Program

Once the JDK is installed, you can create a simple "Hello, World!" program to verify that everything is set up correctly. Create a file named `HelloWorld.java` with the following content:

```java
public class HelloWorld {
  public static void main(String[] args) {
    System.out.println("Hello, World!");
  }
}
```

Save the file and open a terminal. Navigate to the directory containing the file and compile the program using:

```bat
javac HelloWorld.java
```

Run the compiled program with:

```bat
java HelloWorld
```

If everything is set up correctly, you should see the output: Hello, World!

### Conclusion

Java's versatility, portability, and strong features make it a popular choice for a wide range of applications, from web development to mobile apps and enterprise-level systems. Learning Java provides a solid foundation for anyone entering the world of programming.
