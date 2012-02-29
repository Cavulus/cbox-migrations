/**
* Abstract Database Adapter
*/
component accessors="true" extends="AbstractAdapter"{

	// PSEUDO STATIC TYPES
	this.SQLTYPES = {
		"BINARY" 	= {name='BLOB'},
		"BOOLEAN" 	= {name='TINYINT',limit=1},
		"DATE" 		= {name='DATE'},
		"DATETIME" 	= {name='DATETIME'},
		"DECIMAL" 	= {name='DECIMAL'},
		"FLOAT" 	= {name='FLOAT'},
		"INTEGER" 	= {name='INT'},
		"STRING" 	= {name='VARCHAR',limit=255},
		"TEXT" 		= {name='TEXT'},
		"TIME" 		= {name='TIME'},
		"TIMESTAMP" = {name='DATETIME'}
	}

	// Constructor
	MySQL function init(){
		super.init("MySQL");
		return this;
	}

	<cffunction name="addPrimaryKeyOptions" returntype="string" access="public">
		<cfargument name="sql" type="string" required="true" hint="column definition sql">
		<cfargument name="options" type="struct" required="false" default="#StructNew()#" hint="column options">
		<cfscript>
		if (StructKeyExists(arguments.options, "null") && arguments.options.null)
			arguments.sql = arguments.sql & " NULL";
		else
			arguments.sql = arguments.sql & " NOT NULL";
		
		if (StructKeyExists(arguments.options, "autoIncrement") && arguments.options.autoIncrement)
			arguments.sql = arguments.sql & " AUTO_INCREMENT";
		
		arguments.sql = arguments.sql & " PRIMARY KEY";
		</cfscript>
		<cfreturn arguments.sql>
	</cffunction>

	<!---  MySQL uses angle quotes to escape table and column names --->
	<cffunction name="quoteTableName" returntype="string" access="public" hint="surrounds table or index names with quotes">
		<cfargument name="name" type="string" required="true" hint="column name">
		<cfreturn "`#Replace(arguments.name,".","`.`","ALL")#`">
	</cffunction>

	<cffunction name="quoteColumnName" returntype="string" access="public" hint="surrounds column names with quotes">
		<cfargument name="name" type="string" required="true" hint="column name">
		<cfreturn "`#arguments.name#`">
	</cffunction>
	
	<!--- MySQL text fields can't have default --->
	<cffunction name="optionsIncludeDefault" returntype="boolean">
		<cfargument name="type" type="string" required="false" hint="column type">
		<cfargument name="default" type="string" required="false" default="" hint="default value">
		<cfargument name="null" type="boolean" required="false" default="true" hint="whether nulls are allowed">
		<cfif arguments.type eq "text">
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>
	
	<!--- MySQL can't use rename column, need to recreate column definition and use change instead --->
	<cffunction name="renameColumnInTable" returntype="string" access="public" hint="generates sql to rename an existing column in a table">
		<cfargument name="name" type="string" required="true" hint="table name">
		<cfargument name="columnName" type="string" required="true" hint="old column name">
		<cfargument name="newColumnName" type="string" required="true" hint="new column name">
		<cfreturn "ALTER TABLE #quoteTableName(LCase(arguments.name))# CHANGE COLUMN #quoteColumnName(arguments.columnName)# #quoteColumnName(arguments.newColumnName)# #$getColumnDefinition(tableName=arguments.name,columnName=arguments.columnName)#">
	</cffunction>

	/**
	* Rename column
	* @name.hint Name of table
	* @column.hint Name of column to rename
	* @newColumn.hint The name of the new column
	*/
	function renameColumn(required name, required column, required newColumn){
		return "ALTER TABLE #quoteTableName(arguments.name)# CHANGE COLUMN #quoteColumnName(arguments.column)# #quoteColumnName(arguments.newColumn)# #dbinfo.getColumnDefinition(table=arguments.name,column=arguments.column)#">
	}

	/**
	* Remove a database index
	* @table.hint The table name
	* @indexName.hint The name of the index
	*/
	function removeIndex(required table, required indexName){
		return "DROP INDEX #quoteTableName( arguments.indexName )# ON #quoteTableName( arguments.table )#";
	}

}