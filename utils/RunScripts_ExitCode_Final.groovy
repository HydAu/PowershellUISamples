import groovy.transform.Field
import org.apache.commons.net.smtp.*;
import org.apache.commons.cli.*;

/*
 * execute the commands with an exit code check, timeout and continue option 
 * 
 */

def cli;
def options;

// Keep some variables defined globally
// http://stackoverflow.com/questions/6305910/how-do-we-create-and-access-the-global-variables-in-groovy

// NOTE the path variables will be formatted in cygwin style
@Field String __SCRIPTFILE__ = getClass().protectionDomain.codeSource.location.path.replaceFirst(/^(?:.+\/)?([^\/]+)$/, '$1')
@Field String __SCRIPTPATH__ = new File(getClass().protectionDomain.codeSource.location.path).parent.replaceAll(/%20/, ' ')

@Field env = System.getenv() // java.util.Collections$UnmodifiableMap

@Field boolean DEBUG = false
// the DEBUG specific code has been removed.
// if adding a debugging code decorate with DEBUG check.
@Field boolean CONTINUE = true
@Field Integer __TIMEOUT__ ; __TIMEOUT__ = 30000 // .5 min - global timeout setting
@Field boolean __EXPERIMENTAL__; __EXPERIMENTAL__ = false 

def run_command(String process_command){
	def output =''
	def processExecutable  = ''
	def processArgs = '' 
	if (__EXPERIMENTAL__) {
		println "Processing ${process_command}"
		// NOTE '==~' requires a full line match
		if (process_command =~ /sqlcmd\b/){
			processExecutable = 'sqlcmd'
			processArgs = process_command.replaceFirst(processExecutable, '' )

		} else if (process_command =~ /sqlplus\b/) {
			processExecutable = 'sqlplus'
			processArgs = process_command.replaceFirst(processExecutable, '' )
		} else {
			 new Exception("Please Check the command: ${process_command}")
		}
		println "\"${processExecutable}\"\t${processArgs}" 
		output = runScriptsExitCodeandDurarionCheck processExecutable, processArgs
		println output
	} else {
		println process_command
		output = process_command.execute().text 
		println output
	}
	return output
}




def runScriptsExitCodeandDurarionCheck(String processExecutable, String processArgs) {
	def status = 0
	def command_output = ''
	def command_error = ''
	def command = "${processExecutable} ${processArgs}"
	def command_exception = ''

	def ant = new AntBuilder() // create an antbuilder

	try {
		command_exception = null
		ant.exec(outputproperty:'command_output',
		errorproperty: 'command_error',
		resultproperty:'command_exitstatus',
		failonerror: 'true',
		timeout: __TIMEOUT__,
		executable: processExecutable) { arg(line:processArgs ) }
		// closure
	} catch (e) {
		// save the stack tarce into a string variable
		StringWriter errors = new StringWriter();
		e.printStackTrace(new PrintWriter(errors));
		command_exception = errors.toString();
	} finally {
		println "Command:  ${processExecutable} ${processArgs}"
		if (command_exception != null && command_exception != '') {
			status = 255
			if (command_exception =~ /Timeout/) {
				println "Timeout exception...: ${command_exception}"
			} else {
				println "Unspecified exception... \n${command_exception}"
			}
		} else {
			status = ant.project.properties.command_exitstatus.toInteger()
		}
		command_output = ant.project.properties.command_output
		command_error = ant.project.properties.command_error
		ant = null
	}
	//  end executing the command

	if (!CONTINUE) {
		assert status == 0 : "Command exited with status ${status}\n${command_output}\n${command_error}"
	}

	if (status == 0) {
		def lines = command_output.split('\r')
		if (!CONTINUE) {
			assert lines instanceof String[]
			assert lines.length != 0 : "Command output should not be empty"
		}
		nonBlankLine = lines.find { line -> line =~ /\S/ }
		if (!CONTINUE) {
			assert nonBlankLine != null : "Command output should not be blank"
		}
		//if (!process_log(command_output, 'Msg ')) {
		//	status = 128
		//}
		if (!CONTINUE) {
			assert status == 0 : "Command output contains error(s):\n${command_output}"
		}
	}
	// done processing the command output

	// merge command_output and command_error
	// allowing  the caller to print to the console
	command_result = [
		command_output,
		command_error
	].join('\n')
	return command_result
}

// old version will still fit.
// define method to process the sql command results
def process_results(ArrayList script, String command_output, File errorLog) {
	if (script.hostType.get(0).text() == 'SQLServer' && !process_log(command_output, 'Msg ')) {
		errorLog << 'File Name: ' + script.undoRun.get(0).text() + '\n'+ output + '\n\n\n'
		println "Found ERROR adding Error log to Error.txt file"
	} else if (script.hostType.get(0).text() == 'Oracle' && !process_log(command_output,'ERROR ')) {
		errorLog << 'File Name: ' + script.undoRun.get(0).text() + '\n'+ output + '\n\n\n'
		println "Found ERROR adding Error log to Error.txt file"
	} else {
		throw new Exception("Please Check the xml")
	}
}

// NOTE : fails when output is BLANK or contains error_message_fragment
def process_log2(String log, String error_message_fragment) {
	def lines = log.split('\r')
	boolean log_is_clean = true

	if (!CONTINUE && lines.length == 0) {
		println 'Command output should not be empty'
		log_is_clean = false
	}
	def nonBlankLine = lines.find { line -> line =~ /\S/ }
	if (!CONTINUE && nonBlankLine == null) {
		println 'Command output should not be blank'
		log_is_clean = false
	}
	// this code should move to a different function.
	lines.each() { line ->
		if (line != null && line.contains(error_message_fragment)) {
			log_is_clean = false
		}
	}
	return log_is_clean
}

// NOTE : preserved the legacy logic when BLANK output is OK
def process_log(String log, String error_message_fragment) {
	boolean log_is_clean = true
	if (log == null || log == '') {
		log_is_clean = true
		return log_is_clean
	}

	def log_lines = log.split('\r')

	log_lines.each() { line ->
		if (line != null && line.contains(error_message_fragment)) {
			log_is_clean = false
		}
	}
	return log_is_clean
}

//---------- Main script

cli = new CliBuilder(usage: " groovy ${__SCRIPTFILE__} [options] <sql_script>",
header: 'Options:')
cli.with {
	h longOpt: 'help', 'Show usage'

	d longOpt: 'debug', 'Print debug information during the run'
	c longOpt: 'continue', 'Continue after error'
	t longOpt: 'timeout', 'timeout for SQL scripts', required: false, args: 1
}

// The following can be combined with cli.with
cli.s(longOpt: 'server', 'server to connect to', required: true, args: 1 ) 
cli.U(longOpt: 'login', 'login id', required: true, args: 1 ) 
cli.P(longOpt: 'password', 'password', required: true, args: 1 ) 
cli.i(longOpt: 'instance', 'instance on the server', required: false, args: 1 ) 

options = cli.parse(args)
if(!options) {  
	return  
}  

def arguments = options.arguments()

// Show usage text when -h or --help option is used.
if (options.h) {
	cli.usage()
	println "Example:\n" + 
                "groovy RunScripts_ExitCode_Final.groovy   -t 10000 -s sqlclnp04 -i uat03 good_script.sql"
	return
}

//---


__EXPERIMENTAL__ = true

//--- 
assert arguments.size > 0 : 'Need the sql script to run'
def doSQL = arguments[0]
if (options.t && null!= options.t && '' != options.t ) {
     __TIMEOUT__ =  options.t.toInteger()
}
DEBUG |= options.d
CONTINUE |= options.c

login_id = options.U
password = options.P
def processExecutable = 'sqlcmd'
def dest = ( options.instance )? [ options.server, options.instance ].join('\\') : options.server
processArgs = "-U ${login_id} -P ${password} -S ${dest}  -t ${__TIMEOUT__} -i \"${doSQL}\""
println processArgs
text = runScriptsExitCodeandDurarionCheck processExecutable, processArgs

println text



println "The script ${__SCRIPTFILE__} continues execution ..."
return 
// sensitive on master 
System.exit(1)
