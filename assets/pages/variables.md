# Variables

In Java and Python, Variables are the data containers that save the data values during program execution. Every variable is assigned a data type that designates the type and quantity of value it can hold. A variable is a memory location name for the data.

## How to Declare Variables

### Declaring Variables in Java
In Java, declaring a variable involves specifying the type of the variable and giving it a name. The declaration does not assign a value to the variable (though it can be combined with initialization). Here's the principle of declaring variables in Java:

**Data Type:** Start with the data type that indicates the kind of value the variable will hold (e.g., `int`, `double`, `char`, `String`, etc.).

**Variable Name:** Follow the data type with a valid variable name that follows Java naming conventions (e.g., starting with a letter, no spaces, no special characters except `_` and `$`).

 **Semicolon:** End the declaration statement with a semicolon (`;`). In this way, a name can only be given to a memory location. It can be assigned values in two ways:


### Declaring Variables in Python

In Python, declaring a variable is straightforward because there is no need to explicitly define its type. Variables are dynamically typed, meaning that Python determines the type based on the value assigned. Here's the principle of declaring variables in Python:

****Variable Name:**** Choose a name that follows Python's naming conventions (start with a letter or underscore, no special characters except underscores, no spaces).

****Assignment Operator:**** Use the assignment operator (`=`) to assign a value to the variable.

****Value:**** The value assigned can be of any type (integer, string, list, etc.).

## How to Initialize Variables in Java?

It can be perceived with the help of 3 components that are as follows:

-   ****datatype****: Type of data that can be stored in this variable.
-   ****variable_name****: Name given to the variable.
-   ****value****: It is the initial value stored in the variable.

****Illustrations:****
```java
// Declaring float variable  
float simpleInterest;   
// Declaring and initializing integer variable  
int time = 10, speed = 20;   
// Declaring and initializing character variable  
char var = 'h';   
```
## How to Initialize Variables in Python?

-   **Variable Name:** Choose a name following Python’s naming conventions.
-   **Assignment Operator:** Use the `=` sign to assign a value to the variable.
-   **Value:** Assign any value, which can be of any data type (e.g., integer, string, list, etc.).

****Illustrations:****
```python
# Initializing different types of variables
age = 25                 # Integer
name = "Alice"           # String
height = 5.9             # Float
is_student = True        # Boolean
```

 <quiz quiz-id="variable-quiz-1">

## Types of Variables in Java

Now let us discuss different types of variables which are listed as follows:

1.  Local Variables
2.  Instance Variables
3.  Static Variables

Let us discuss the traits of every type of variable listed here in detail.

### ****1. Local Variables****

A variable defined within a block or method or constructor is called a local variable.

-   The Local variable is created at the time of declaration and destroyed after exiting from the block or when the call returns from the function.
-   The scope of these variables exists only within the block in which the variables are declared, i.e., we can access these variables only within that block.
-   Initialization of the local variable is mandatory before using it in the defined scope.

**Example:**
```java
public class LocalVariableExample {
    public static void main(String[] args) {
        // Declaration and initialization of a local variable
        int number = 10;

        // Using the local variable
        System.out.println("The value of the local variable 'number' is: " + number);
    }
}
```

### ****2. Instance Variables****

Instance variables are non-static variables and are declared in a class outside of any method, constructor, or block.

-   As instance variables are declared in a class, these variables are created when an object of the class is created and destroyed when the object is destroyed.
-   Unlike local variables, we may use access specifiers for instance variables. If we do not specify any access specifier, then the default access specifier will be used.
-   Initialization of an instance variable is not mandatory. Its default value is dependent on the data type of variable. For __String__ it is __null,__ for __float__ it  is __0.0f,__ for __int__ it is __0,__ for Wrapper classes like __Integer__ it is __null, etc.__
-   Instance variables can be accessed only by creating objects.
-   We initialize instance variables using constructors while creating an object. We can also use instance blocks to initialize the instance variables.

```java
public class InstanceVariableExample {
    // Declaration of an instance variable
    private int number;

    // Constructor to initialize the instance variable
    public InstanceVariableExample(int num) {
        this.number = num;
    }

    // Method to display the instance variable
    public void displayNumber() {
        System.out.println("The value of the instance variable 'number' is: " + number);
    }

    public static void main(String[] args) {
        // Creating an object of the class
        InstanceVariableExample example = new InstanceVariableExample(25);

        // Accessing the instance variable through a method
        example.displayNumber();
    }
}
```
### ****3. Static Variables****

Static variables are also known as class variables.

-   These variables are declared similarly to instance variables. The difference is that static variables are declared using the static keyword within a class outside of any method, constructor, or block.
-   Unlike instance variables, we can only have one copy of a static variable per class, irrespective of how many objects we create.
-   Static variables are created at the start of program execution and destroyed automatically when execution ends.
-   Initialization of a static variable is not mandatory. Its default value is dependent on the data type of variable. For __String__ it is __null__, for __float__ it is __0.0f__, for __int__ it is __0__, for __Wrapper classes__ like __Integer__ it is __null,__ etc.
-   If we access a static variable like an instance variable (through an object), the compiler will show a warning message, which won’t halt the program. The compiler will replace the object name with the class name automatically.
-   If we access a static variable without the class name, the compiler will automatically append the class name. But for accessing the static variable of a different class, we must mention the class name as 2 different classes might have a static variable with the same name.
-   Static variables cannot be declared locally inside an instance method.
-   Static blocks can be used to initialize static variables.


```java
public class StaticVariableExample {
    // Declaration of a static variable
    private static int counter = 0;

    // Constructor that increments the static variable
    public StaticVariableExample() {
        counter++;
    }

    // Static method to display the static variable
    public static void displayCounter() {
        System.out.println("The value of the static variable 'counter' is: " + counter);
    }

    public static void main(String[] args) {
        // Creating objects of the class
        StaticVariableExample obj1 = new StaticVariableExample();
        StaticVariableExample obj2 = new StaticVariableExample();
        StaticVariableExample obj3 = new StaticVariableExample();

        // Accessing the static variable through a static method
        StaticVariableExample.displayCounter(); // Output: 3
    }
}
```

<quiz quiz-id="variable-quiz-2">

## Types of Variables in Python

In Python, variables are categorized based on their scope, lifetime, and usage within a program. Here are the main types of variables:

### 1. **Local Variables:**

-   **Scope:** Limited to the function or block where they are declared.
-   **Lifetime:** Exists only while the function or block is executing.
-   **Usage:** Typically used for temporary storage within a function.

**Example:**

```python
def my_function():
    local_var = 10  # Local variable
    print(local_var)

my_function()
# print(local_var)  # This would raise an error since local_var is not accessible outside the function` 
```

### 2. **Global Variables:**

-   **Scope:** Accessible throughout the entire program, including inside functions (if declared global within the function).
-   **Lifetime:** Exists for the duration of the program’s execution.
-   **Usage:** Used for data that needs to be shared across different parts of the program.

**Example:**

```python
global_var = 20  # Global variable

def my_function():
    print(global_var)  # Accessing global variable inside a function

my_function()
print(global_var)  # Accessing global variable outside the function` 
```

### 3. **Instance Variables:**

-   **Scope:** Belong to a specific instance of a class and are accessed using `self`.
-   **Lifetime:** Exists as long as the instance (object) exists.
-   **Usage:** Store data unique to each object of the class.

**Example:**

```python
class MyClass:
    def __init__(self, value):
        self.instance_var = value  # Instance variable

    def display(self):
        print(self.instance_var)

obj1 = MyClass(10)
obj2 = MyClass(20)
obj1.display()  # Output: 10
obj2.display()  # Output: 20` 
```

### 4. **Class Variables (Static Variables):**

-   **Scope:** Belong to the class and are shared among all instances of the class.
-   **Lifetime:** Exists as long as the class is in memory.
-   **Usage:** Store data that should be shared across all instances of the class.

**Example:**

```python
class MyClass:
    class_var = 0  # Class variable

    def __init__(self):
        MyClass.class_var += 1  # Modifying the class variable

obj1 = MyClass()
obj2 = MyClass()
print(MyClass.class_var)  # Output: 2` 
```
### 5. **Constants:**

-   **Scope and Lifetime:** Similar to global variables, but their values are intended to remain unchanged.
-   **Usage:** Store values that should not be altered during the program's execution.

**Note:** Python doesn't have built-in constant types. However, by convention, constants are written in all uppercase letters.

**Example:**

```python
PI = 3.14159  # Constant by convention

def calculate_circumference(radius):
    return 2 * PI * radius

print(calculate_circumference(5))` 
```
### 6. **Nonlocal Variables:**

-   **Scope:** Used inside nested functions; they refer to variables in the nearest enclosing scope that is not global.
-   **Usage:** To modify variables in an outer (but not global) scope from within a nested function.

**Example:**

```python
def outer_function():
    nonlocal_var = "Hello"

    def inner_function():
        nonlocal nonlocal_var
        nonlocal_var = "World"
    
    inner_function()
    print(nonlocal_var)  # Output: World

outer_function()`
```

<quiz quiz-id="variable-quiz-3">

### With that you can now proceed with the story by finishing this challenge.

<challenge challenge-id="hello-world">