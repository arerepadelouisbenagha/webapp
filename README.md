# webapp

## follow to create this shopping application.
- Set up your Nginx server and install MySQL on your server.
- Create a database and tables in MySQL to store your product information, user information, and order information.
- Create an HTML file that will serve as the front end for your shopping application. This file should include a form for users to enter their information and select products to purchase.
- Style your HTML file with CSS to make it visually appealing and easy to use.
- Write PHP code to handle form submission and interaction with the MySQL database. This code will validate user input, add products to the user's cart, and process payment information.
- Set up a checkout process that will securely process payment information and finalize the order.
- Test your application to ensure it is working correctly.

### The Technologies Used in this Project are:-
- HTML
- CSS
- Javascript
- Bootstrap
- Java
- JDBC
- JSP
- Servlets
- MySql

## database commands
```MySQL
create database shopping;
use shopping;

create table user(name varchar(20),mobile bigint(12),email varchar(40) primary key, address varchar(150),pincode integer(6),password varchar(20));

create table admin(username varchar(30) primary key, password varchar(30));

create table product(pid varchar(16) primary key,pname varchar(20),ptype varchar(20),pinfo varchar(150),pprice decimal(12,2),pquantity int(10),image blob);

create table usercart(username varchar(40), prodid varchar(16),quantity int(4));

create table admin(company varchar(30), email varchar(30), username varchar(30), password varchar(30));

alter table usercart add foreign key (prodid) references product(pid) on delete cascade;

alter table usercart add foreign key (username) references user(email) on delete cascade;

create table transactions(transid varchar(16) primary key,username varchar(40) references user(email) on delete cascade,time datetime, amount decimal(10,2));

create table orders(transid varchar(16) references transactions(transid) on delete cascade, prodid varchar(16) references product(pid) on delete cascade,quantity int(4), amount decimal(10,2), primary key(transid,prodid));

create table user_demand(username varchar(40) references user(email) on delete cascade, prodid varchar(16) references product(pid) on delete cascade, quantity int(4), primary key(username,prodid));

```