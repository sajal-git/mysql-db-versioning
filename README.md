Refer URL : http://goo.gl/gnvL73

MAVEN AND DBDEPLOY 
- Apache Maven is a mature tool in widespread use for automating common compile-deploy-test operations. 
- Ant works by executing commands in a build file. 
- A build file contains targets – a unit of work that accomplishes a specific job. 
- At the lowest level of granularity, a target contains one or more tasks – these are the individual steps required to complete the specific job. 


How It Works

1. Looks for delta scripts in a specified directory for .sql files and orders them by name. This explains the importance of each refactoring script name beginning with an incremental number. 
2. Reads the content of the changelog table in the specified database. The changelog table contains a record of all database refactorings that have been applied to the database. 
3. Establishes which database refactorings have not been run against the specified database. With this knowledge it generates a script containing all of the refactorings to be applied. 


DBDeploy Plugin

 <plugin>
                                        <groupId>com.dbdeploy</groupId>
                                        <artifactId>maven-dbdeploy-plugin</artifactId>
                                        <version>3.0M3</version>
                                        <configuration>
                                                <driver>com.mysql.jdbc.Driver</driver>
                                                <dbms>mysql</dbms>
                                                <delimiter>;</delimiter>
                                                <delimiterType>row</delimiterType>
                                        </configuration>
                                        <dependencies>
                                                <dependency>
                                                        <groupId>mysql</groupId>
                                                        <artifactId>mysql-connector-java</artifactId>
                                                        <version>5.1.18</version>
                                                </dependency>
                                                <dependency>
                                                        <groupId>commons-lang</groupId>
                                                        <artifactId>commons-lang</artifactId>
                                                        <version>2.5</version>
                                                </dependency>
                                        </dependencies>
                                </plugin>



Reading configurations from properties file

  <plugin>
            <groupId>org.codehaus.mojo</groupId>
            <artifactId>properties-maven-plugin</artifactId>
            <version>1.0-alpha-2</version>
            <executions>
                        <execution>
                                    <phase>initialize</phase>
                                    <goals>
                                            <goal>read-project-properties</goal>
                                    </goals>
                                    <configuration>
                                                    <files>
                                                            <file>db.properties</file>
                                                    </files>
                                    </configuration>
                        </execution>
            </executions>
</plugin>



Defining Profiles for Database

<profiles>
    <profile>
        <id>db-profile</id>
            <activation>
                    <activeByDefault>true</activeByDefault>
            </activation>
            <build>
                <plugins>
                    <plugin>
                            <groupId>com.dbdeploy</groupId>
                            <artifactId>maven-dbdeploy-plugin</artifactId>
                            <executions>
                                    <execution>
                                            <id>db-id</id>
                                            <phase>install</phase>
                                            <goals>
                                                <goal>db-scripts</goal>
                                                <goal>update</goal>
                                                </goals>
                                                <configuration>
                                                    <url>${url}</url>
                                                    <userid>${userid}</userid>
                                                    <password>${password}</password>
                                                    <changeLogTableName>${changelog}</changeLogTableName>
                                                    <scriptdirectory>${patch_directory}</scriptdirectory>
                                                    <outputfile>${outputfile}</outputfile>
                                                    <undoOutputfile>${undoOutputfile}</undoOutputfile>
                                                </configuration>
                                    </execution>
                            </executions>
                    </plugin>
                </plugins>
            </build>
    </profile>
</profiles>




Rules for using dbdeploy

When creating a delta file you will need to follow these conventions:
1. Make sure that every database modification is written as a delta script to be picked up by dbdeploy.

2. You must follow the naming convention for delta scripts. Script names must begin with a number that indicates the order in which it should be run (1.sql gets run first, then 2.sql and so on). You can optionally add a comment to the file name to describe what the script does (eg 101_adding-foo-table.sql) the comment will get written to the schema version table as the script is applied.

3. You can optionally add an undo section to your script. Write the script so it performs the do action first, once all do actions have been scripted include the token --//@UNDO on a new line. Include the undo steps after this token.



Example

A developer needs to modify the database by adding a new table called foo. It is the third database modification to be written.
Create a file called 101_adding-foo-table.sql
The content of the file looks like this:
CREATE TABLE FOO (
FOO_ID INTEGER NOT NULL,
FOO_VALUE VARCHAR(30)
);

ALTER TABLE FOO ADD CONSTRAINT PK_FOO PRIMARY KEY (FOO_ID)
;

--//@UNDO

DROP TABLE FOO
;


A note of caution
dbdeploy works by checking to see if a particular delta script has been run against a particular database. To do this it uses the name of the delta script plus the name of the delta set (which will be "All" unless otherwise specified) and compares this against the content of the schema version table. If a delta script that has already been applied to a database is subsequently modified that subsequent modification will not be applied to the database.
In most circumstances the answer to amending what’s been done in a delta script is to just write another delta script.


Example Directory structure

pom.xml : contains maven and db deploy plugin configration
db.properties : properties file having required details to be used in pom.xml
output_here.sql : dynamically updated after every build alongwith changelog update
undo_script.sql : dynamically updated after every build for undo scripts passed in delta script files alongwith changelog rollback
mysql-patch : this directory contains delta scripts for .sql files ordered in specified format.


Live Demo ::

-- Create test database
$ mysql -u root -p
mysql> create database test_db;


-- Grant permission to localhost and jenkins server
mysql> GRANT ALL on *.* to 'root'@'localhost_ip' identified by 'p2ssw0rd';
mysql> GRANT ALL on *.* to 'root'@'jenkins_ip’' identified by 'p2ssw0rd';
mysql> GRANT PRIVILEGES;


-- Creating Changelog table to record all database refactorings
mysql> use test_db;
mysql> CREATE TABLE CHANGELOG (change_number INTEGER NOT NULL,complete_dt TIMESTAMP NOT NULL,applied_by VARCHAR(100) NOT NULL,description VARCHAR(500) NOT NULL);
mysql> ALTER TABLE CHANGELOG ADD CONSTRAINT Pkchangelog PRIMARY KEY (change_number);


-- Add delta scripts to mysql-patch directory
$ cd /opt/dbversioning/
$ vim mysql-patch/101_adding-foo-table.sql
CREATE TABLE FOO (
FOO_ID INTEGER NOT NULL,
FOO_VALUE VARCHAR(30)
);
ALTER TABLE FOO ADD CONSTRAINT PK_FOO PRIMARY KEY (FOO_ID);

--//@UNDO
DROP TABLE FOO;


-- Create build to be deployed
$ mvn clean install


-- Now required db query is run on server and is updated as required
$  mysql -u root -p
mysql> use test_db;
mysql> describe FOO;


-- Passing another delta files to update the database
$ vim mysql-patch/102_alter-foo-table.sql
ALTER TABLE FOO ADD (
FOO_DATE DATE NULL);


--//@UNDO
ALTER TABLE FOO DROP COLUMN FOO_DATE;

$ mvn clean install



-- All the delta scripts versioning is done in changelog table

-- Similarly we can pass multiple scripts to update the database

$ vim mysql-patch/103_alter-foo-add-column.sql
ALTER TABLE FOO ADD (
FOO_AGE INTEGER NULL);

--//@UNDO
ALTER TABLE FOO DROP COLUMN FOO_AGE;

$ vim mysql-patch/104_update-foo-table.sql
INSERT INTO `FOO` VALUES (1,'sajal',STR_TO_DATE('10-08-2016', '%d-%m-%Y'),26),(2,'sj',STR_TO_DATE('11-08-2016', '%d-%m-%Y'),27),(3,'sajalj',STR_TO_DATE('10-08-2016', '%d-%m-%Y'),27);

--//@UNDO
DROP TABLE FOO;

$ mvn clean install

$ mysql -u root -p


