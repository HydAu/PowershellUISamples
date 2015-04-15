package artifactory

import groovy.text.SimpleTemplateEngine
import groovyx.net.http.RESTClient
import net.sf.json.JSON
import groovy.json.JsonOutput
import groovy.transform.Field
import groovy.time.*


/**
* This groovy class is meant to be used to clean up your Atifactory server or get more information about it's
* contents. The api of artifactory is documented very well at the following location
* {@see http://wiki.jfrog.org/confluence/display/RTF/Artifactory%27s+REST+API}
*
* @author Jettro Coenradie
*/
private class Artifactory {

def printErr = System.err.&println  
def engine = new SimpleTemplateEngine()
def config
def browse_max_level = 2
def findfolder_result 
def artifactory_entries = [] 
def Artifactory(config) {
	this.config = config
  // todo mate a paeameter 
  this.browse_max_level = 4
}
  
 /**
 * TODO: wrapper around Artifactory File Statistics REST API  
 * {
 *   "uri": "http://localhost:8080/artifactory/api/storage/libs-release-local/org/acme/foo/1.0/foo-1.0.jar",
 *   "lastDownloaded": Timestamp (ms),
 *   "downloadCount": 1337,
 *   "lastDownloadedBy": "user1"
 * }
 */
 def fstat_entries() {
   // TODO
 }
 /**
 * Print the data, before any sorting or filtering
 */
    def print_entries() {
    	def count = 0
    	println(this.artifactory_entries.size)
    	println(config.keep_builds)
    	Integer last_count = this.artifactory_entries.size.toInteger()
    	last_count -= config.keep_builds.toInteger()
        // NOTE: whitespace-sensitive 
    	artifactory_entries.sort{a,b -> a.created <=> b.created }.each {
    		def symbol = (count < last_count) ? '*' : ' '
    		println(sprintf('%1$s|%2$s|%3$s|%4$s', [it.created, symbol, count, it.path]))
    		count++
    	}
    }
  
/**
* Print information about all the available repositories in the configured Artifactory
*/
def printRepositories() {
  def server
  try {
	server = obtainServerConnection()
  } catch (all){
    printErr "FATAL: no server connection"
    throw new Exception() 
  }
  def rootpath = '/artifactory/api/repositories'
	/*
TODO:
Caught: groovyx.net.http.HttpResponseException: Not Found
        at artifactory.Artifactory.printRepositories(A.groovy:62)
*/
	def resp = server.get(path: rootpath)
	if (resp.status != 200) {
		printErr "FATAL: server.get: " + resp.status
		System.exit(-1)
	}
	JSON json = resp.data
	json.each {
      println(sprintf("key : %s\r\ntype :%s\r\ndescription :%s\r\nurl :%s\r\n", it.key,it.type , it.description, it.url ))
		/*println 'key :' + it.key
		println 'type : ' + it.type
		println 'description : ' + it.description
		println 'url : ' + it.url
		println ''*/
	}
}
  
  
  /**
* Return information about the provided path for the configured artifactory and server.
*
* @param path String representing the path to obtain information for
*
* @return JSON object containing information about the specified folder
*/
def JSON folderInfo(path) {
	def binding = [repository: config.repository, path: path]
  def template = engine.createTemplate( '''/artifactory/api/storage/$repository/$path''' ).make(binding)
	def query = template.toString()
	def server = obtainServerConnection()
	def resp = server.get(path: query)
	if (resp.status != 200) {
		printErr "ERROR: problem obtaining folder info: " + resp.status
		printErr query
		System.exit(-1)
	}
	return resp.data
}
  
/**
* http://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
*
* @param path String representing the path to obtain information for
*
* @return JSON object containing information about the specified folder
*/
def JSON fileInfo(path) {
	def binding = [repository: config.repository, path: path]
  def template = engine.createTemplate( '''/artifactory/api/storage/$repository/$path''' ).make(binding)
	def query = template.toString()
	def server = obtainServerConnection()
    /*
       Caught: org.codehaus.groovy.runtime.typehandling.GroovyCastException: Cannot cast object 'java.io.ByteArrayInputStream@19e09a4' with class 'java.io.ByteArrayInputStream' to class 'net.sf.json.JSON'
    */ 
	def resp = server.get(path: query)
	if (resp.status != 200) {
		printErr "ERROR: problem obtaining folder info: " + resp.status
		printErr query
		System.exit(-1)
	}

    // println(groovy.json.JsonOutput.prettyPrint(resp.data.toString()))  
	return resp.data
}
  
  
def findFolders(String target_folder_name, String path, Integer browse_level) {
	def result

	if (browse_level > browse_max_level) {
		return; // empty
	}
	// TODO: terminator
	if (path =~ /\b${target_folder_name}\b/  ) {
      result = path 
      browse_level = browse_max_level + 1 
      findfolder_result = result 
      return;
    }

	JSON json = folderInfo(path)
    
	json.children.each {
		child ->
        
		if ( child.folder.toBoolean() ) {
          return findFolders(target_folder_name, path + child.uri, browse_level + 1) 
        }
    }
    
}
/**
* Recursively removes all folders containing builds that start with the configured paths.
*
* @param path String containing the folder to check and use the childs to recursively check as well.
* @return Number with the amount of folders that were removed.
*/
  
def cleanArtifactsRecursive(path) {
    // TODO : browse_max_level too?
	def deleteCounter = 0
	JSON json = folderInfo(path)
    
	json.children.each {
		child ->
        def child_is_folder = child.folder.toBoolean()
		if ( child_is_folder   == true ) {
           assert child_is_folder
			if (isBuildFolder(child)) {
				// build folder logic 
				config.versionsToRemove.each {
					toRemove -> 
					if (child.uri.startsWith(toRemove)) {
						removeItem(path, child)
						deleteCounter++
					}
				}
			} else {
                // confinue recursing 
				if (!child.uri.contains("ro-scripts")) {
					deleteCounter += cleanArtifactsRecursive(path + child.uri)
				}
           
			}
        } else {
          // file
          try {
            JSON fileinfo_json = fileInfo(path + child.uri)
            
            def artifact_entry = ['path' : fileinfo_json.path,'repo' : fileinfo_json.repo, 'uri' : fileinfo_json.uri, 'created' : fileinfo_json.created ]
            artifactory_entries.push ( artifact_entry )
          } catch(all){}
          removeItem(path,  child )
        }
	}
	return deleteCounter
}
  
private RESTClient obtainServerConnection() {
	def server = new RESTClient(config.server)
	server.auth.basic config.user, config.password
	server.parser.
	'application/vnd.org.jfrog.artifactory.storage.FolderInfo+json' = server.parser.
	'application/json'
	server.parser.
	'application/vnd.org.jfrog.artifactory.storage.FileInfo+json' = server.parser.
	'application/json'

	server.parser.
	'application/vnd.org.jfrog.artifactory.repositories.RepositoryDetailsList+json' = server.parser.
	'application/json'
	return server
}
  
// http://codebeautify.org/javaviewer 
private def isBuildFolder(child) {
	child.uri.contains("-build-")
}
  
private def removeItem(path, child) {
	if (config.powerles) {
		println "folder: " + path + child.uri + " DELETE"
	} else {
		def binding = [repository: config.repository, path: path + child.uri]
		def template = engine.createTemplate('''/artifactory/$repository/$path''').make(binding)
		def query = template.toString()
		// println(query)
		if (!config.dryRun) {
			def server = new RESTClient(config.server)
			server.delete(path: query)
		}
	}
}
  

}


 @Field std_env = System.getenv()

 def timeStart = new Date()

 def config = [
 rootfolder: std_env['ARTIFACTORY_APPLICATIONS_ROOTFOLDER'],
 application_folder: std_env['APPLICATION_FOLDER'],
 powerless: std_env['POWERLESS'],

 keep_builds: std_env['RECENT_BUILDS_KEEP'],
 server: std_env['ARTIFACTORY_URL'],
 user: std_env['ARTIFACTORY_USER'],
 password: std_env['ARTIFACTORY_PASSWORD'],
 repository: std_env['ARTIFACTORY_REPOSITORY'],
 versionsToRemove: ['/1.1-SNAPSHOT'], // unused 
 dryRun: true]
 // TODO: 
 println 'Started.'
 def artifactory = new Artifactory(config)

if ( std_env['LIST_APPLICATIONS_ROOTFOLDERS'].toBoolean() ) {
   artifactory.printRepositories() 
}
 
 
 // TODO - handle redundant and invalid inputs
 def find_folder = config.application_folder
 println(sprintf('Finding %s in %s' , config.application_folder, config.rootfolder ) )
 artifactory.findFolders(config.application_folder, config.rootfolder, 1)
 println('result=' + artifactory.findfolder_result)
println ('Enumerating artifacts in ' + artifactory.findfolder_result )
 start_folder = artifactory.findfolder_result
 // artifactory.print_entries()
 def numberRemoved = artifactory.cleanArtifactsRecursive(start_folder)
 artifactory.print_entries()


 def timeStop = new Date()
 TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
 println duration
