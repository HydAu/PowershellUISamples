// Initializes Script Parameters via merging default and JOB  environments
@Field std_env = System.getenv()

def required_params = ['DUMMY',  'ARTIFACTORY_URL', 'ARTIFACTORY_USER', 'ARTIFACTORY_PASSWORD', 'APPLICATION_FOLDER', 'RECENT_BUILDS_KEEP', 'ARTIFACTORY_REPOSITORY', 'ARTIFACTORY_APPLICATIONS_ROOTFOLDER' , 'BROWSE_MAX_LEVEL', 'POWERLESS']
def default_env = [
        'DUMMY' :  true,
	'ARTIFACTORY_URL' : 'http://localhost:8080',
	'ARTIFACTORY_USER' : 'sergueik',
	'ARTIFACTORY_PASSWORD' : '',
	'APPLICATION_FOLDER' : 'app',
	'RECENT_BUILDS_KEEP' : '3',
	'ARTIFACTORY_REPOSITORY' : 'libs-snapshot-local',
	'ARTIFACTORY_APPLICATIONS_ROOTFOLDER' : '/com',
	'BROWSE_MAX_LEVEL' : 2,
	'POWERLESS' : 'true',
        'JOB_DEBUG': false 
]
def all_env = [:]
std_env = System.getenv()
// NOTE  the hash loading order
all_env <<= default_env
all_env <<= std_env

all_env << ['DUMMY' : false ]

assert all_env['DUMMY'].toBoolean() == false 

if (!!all_env['JOB_DEBUG']){
  println 'Run in debug mode: JOB_DEBUG = true'  
}

// Lock to Windows OS, just for fun
assert all_env.containsKey('USERPROFILE')



// assert all required parameters are present 
required_params.each {
	setting -> assert all_env.containsKey(setting)

}

//  Ensure the password is set
assert all_env.get('ARTIFACTORY_PASSWORD') !=  ''

// end initialization 
