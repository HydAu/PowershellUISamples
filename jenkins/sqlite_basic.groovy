// see log_filter.pl

@Field boolean DEBUG = false

jar_filename = 'sqlite-jdbc-3.8.7.jar'
def jar_file = new File(jar_filename)
assert jar_file.exists()
this.getClass().classLoader.rootLoader.addURL(jar_file.toURL())


import groovy.transform.Field

@Field env = System.getenv()
import groovy.sql.Sql

database_file = 'test.sqlite'


// http://www.codereactor.net/sqlite-in-groovy-crash-course/
// http://mvnrepository.com/artifact/org.xerial/sqlite-jdbc/3.8.7

// note the capitalization -  static class method
def provider = Sql.newInstance(sprintf('jdbc:sqlite:%s', database_file), 'org.sqlite.JDBC')
assert provider  != null


//  compare database_init ($$$) ...
def database_init(provider) {
	stmt = ''' 
   CREATE TABLE LOGS(
	   FILENAME CHAR(256) PRIMARY KEY NOT NULL,
	   APPLICATION CHAR(256),
	   AGE INT NOT NULL,
	   RESULT CHAR(256),
	   TOTAL_ROWS REAL,
	   SELECTED_ROWS REAL
   );
'''

	// http://mrhaki.blogspot.com/2009/09/groovy-goodness-exception-handling.html
	try {
		provider.execute(stmt)
	} catch (all) {
		assert all in java.sql.SQLException
		/*
		 * Caught: java.sql.SQLException: [SQLITE_ERROR] SQL error or missing database (table LOGS already exists)
		 *        at sqlite_basic.run(sqlite_basic.groovy:47)
		 */
	}
}

def metadata = provider.connection.getMetaData()
@Field tablename = 'LOGS'
def tables = metadata.getTables(null, null, tablename, null)
if (!tables.next()) {
	// table does not exist
	println sprintf('The table "%s" is not defined in this database yet' , tablename  )
        database_init(provider)
} else {
	// table exists.
	tables.each {
		println(it.getClass().toString())
	}
}

