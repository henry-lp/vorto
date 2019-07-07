/**
 * Copyright (c) 2019 Contributors to the Eclipse Foundation
 *
 * See the NOTICE file(s) distributed with this work for additional
 * information regarding copyright ownership.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * https://www.eclipse.org/legal/epl-2.0
 *
 * SPDX-License-Identifier: EPL-2.0
 */
package org.eclipse.vorto.codegen.openapi.templates

import org.eclipse.vorto.codegen.openapi.Utils
import org.eclipse.vorto.core.api.model.datatype.ConstraintIntervalType
import org.eclipse.vorto.core.api.model.datatype.ObjectPropertyType
import org.eclipse.vorto.core.api.model.datatype.PrimitivePropertyType
import org.eclipse.vorto.core.api.model.datatype.PrimitiveType
import org.eclipse.vorto.core.api.model.functionblock.PrimitiveParam
import org.eclipse.vorto.core.api.model.functionblock.RefParam
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate

/**
 * Creates an OpenAPI v3 Specification for an Information Model. Supports configuration, status properties as well as operations
 * 
 */
class OpenAPITemplate implements IFileTemplate<InformationModel> {
	
	override getFileName(InformationModel model) {
		'''«model.name»-openapi-v3.yml'''
	}
	
	override getPath(InformationModel context) {
		return null
	}
	
	override getContent(InformationModel infomodel, InvocationContext context) {
		'''
		### Generated by Eclipse Vorto OpenAPI Generator from Model '«infomodel.namespace»:«infomodel.name»:«infomodel.version»'
		openapi: 3.0.0
		info:
		  title: Bosch IoT Things HTTP API for «infomodel.name» 
		  description: JSON-based, REST-like API for <a href="https://vorto.eclipse.org/#/details/«infomodel.namespace»:«infomodel.name»:«infomodel.version»">«infomodel.name» Vorto Model</a>
		  version: "2"
		servers:
		  - url: https://things.eu-1.bosch-iot-suite.com/api/2
		    description: "Bosch IoT Things Service"
		tags:
		  - name: Features
		    description: Features of your «infomodel.name» things
		  - name: Messages
		    description: Talk with your «infomodel.name»
		security:
		  - thingsApiToken: []
		    bearerAuth: []
		    BoschID: []
		paths:
		  ###
		  ### «infomodel.name» Features
		  ###
		  '/things/{thingId}/features':
		    get:
		      summary: List all features of a «infomodel.name» 
		      description: >-
		        Returns all features of the «infomodel.name» thing identified by the `thingId` path parameter.
		      tags:
		      - Features
		      parameters:
		      - $ref: '#/components/parameters/thingIdPathParam'
		      responses:
		        '200':
		          description: >-
		            The list of features of the «infomodel.name» were successfully retrieved.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/«infomodel.name»Features'
		        '304':
		          $ref: '#/components/responses/notModified'
		        '400':
		          description: |-
		            The request could not be completed. The `thingId` either
		
		              * does not contain the mandatory namespace prefix (java package notation + `:` colon)
		              * does not conform to RFC-2396 (URI)
		
		            Or at least one of the defined query parameters was invalid.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '401':
		          description: The request could not be completed due to missing authentication.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '404':
		          description: >-
		            The request could not be completed. The Thing with the given ID was not found or the Features have not
		            been defined.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '412':
		          $ref: '#/components/responses/preconditionFailed'
		  «FOR fbProperty : infomodel.properties»
		  '/things/{thingId}/features/«fbProperty.name»':
		    get:
		      summary: Retrieve the «fbProperty.name» of the «infomodel.name»
		      description: >-
		        Returns the «fbProperty.name» feature of the «infomodel.name» thing identified by the
		        `thingId` path parameter.
		      tags:
		      - Features
		      parameters:
		      - $ref: '#/components/parameters/thingIdPathParam'
		      responses:
		        '200':
		          description: The «fbProperty.name» was successfully retrieved.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/«fbProperty.type.name»Feature'
		        '304':
		          $ref: '#/components/responses/notModified'
		        '400':
		          description: |-
		            The request could not be completed. The `thingId` either
		              * does not contain the mandatory namespace prefix (java package notation + `:` colon)
		              * does not conform to RFC-2396 (URI)
		            Or at least one of the defined query parameters was invalid.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '401':
		          description: The request could not be completed due to missing authentication.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '404':
		          description: >-
		            The request could not be completed. The Thing with the given ID or the Feature with the specified
		            `featureId` was not found.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '412':
		          $ref: '#/components/responses/preconditionFailed'
		          
		  '/things/{thingId}/features/«fbProperty.name»/definition':
		    get:
		      summary: Lists the Vorto Function Block ID, that the «fbProperty.name» feature complies to
		      description: >-
		        Returns the complete Definition of the «fbProperty.name» identified by the `thingId` path parameter.
		      tags:
		      - Features
		      parameters:
		      - $ref: '#/components/parameters/thingIdPathParam'
		      responses:
		        '200':
		          description: The Definition was successfully retrieved.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/FeatureDefinition'
		        '304':
		          $ref: '#/components/responses/notModified'
		        '400':
		          description: |-
		            The request could not be completed. The `thingId` either
		              * does not contain the mandatory namespace prefix (java package notation + `:` colon)
		              * does not conform to RFC-2396 (URI)
		            Or at least one of the defined query parameters was invalid.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '401':
		          description: The request could not be completed due to missing authentication.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '404':
		          description: >-
		            The request could not be completed. The specified Feature has no Definition or the Thing with the
		            specified `thingId` or the Feature with `featureId` was not found.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '412':
		          $ref: '#/components/responses/preconditionFailed'
		  «IF fbProperty.type.functionblock.configuration !== null && !fbProperty.type.functionblock.configuration.properties.empty»
		  «FOR configurationProperty : fbProperty.type.functionblock.configuration.properties»
		  '/things/{thingId}/features/«fbProperty.name»/properties/configuration/«configurationProperty.name»':
		    put:
		      summary: Sets the device configuration property «configurationProperty.name» of the «fbProperty.name» feature
		      description: |-
		        Sets the «configurationProperty.name» of the «fbProperty.name» feature, identified by the
		        `thingId` path parameter. The set configuration property is transmitted to the device, once the device is connected.
		      tags:
		        - Features
		      parameters:
		        - $ref: '#/components/parameters/thingIdPathParam'
		      responses:
		        '204':
		          description: The Property was successfully updated.
		        '400':
		          description: |-
		            The request could not be completed. The `thingId` either
		              * does not contain the mandatory namespace prefix (java package notation + `:` colon)
		              * does not conform to RFC-2396 (URI)
		            Or the JSON was invalid.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '401':
		          description: The request could not be completed due to missing authentication.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '402':
		          description: The request could not be completed due to exceeded data volume.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '403':
		          description: |-
		            The request could not be completed. Either
		              * due to a missing or invalid API Token.
		              * as the caller had insufficient permissions.
		            For creating/updating a Property of an existing Feature `WRITE` permission is required.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '404':
		          description: |-
		              The request could not be completed. The Thing or the Feature with
		              the given ID was not found.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '412':
		          $ref: '#/components/responses/preconditionFailed'
		        '413':
		          $ref: '#/components/responses/entityTooLarge'
		      requestBody:
		        $ref: '#/components/requestBodies/«fbProperty.type.name»«configurationProperty.name.toFirstUpper»ConfigurationValue'
		  «ENDFOR»
		  «ENDIF»
		  «FOR operation : fbProperty.type.functionblock.operations»
		  '/things/{thingId}/features/«fbProperty.name»/inbox/messages/«operation.name»':
		    put:
		      summary: Executes the «operation.name» on the device
		      description: |-
		        «IF operation.description !== null»«operation.description»«ELSE»Executes the «operation.name» on the device.«ENDIF»
		      
		        The API does not provide any kind of acknowledgement that the
		        message was received by the Feature. In order to send a message, the user needs `WRITE` permission at the Thing level.
		        
		        The HTTP request blocks until a response to the message is available
		        or until the `timeout` is expired. If many clients respond to
		        the issued message, the first response will complete the HTTP request.
		        
		        In order to handle the message in a fire and forget manner, add
		        a query-parameter `timeout=0` to the request.
		      tags:
		        - Messages
		      parameters:
		        - $ref: '#/components/parameters/thingIdPathParam'
		        - $ref: '#/components/parameters/messageTimeoutParam'
		      responses:
		        '202':
		          description: |-
		            The message was sent but not necessarily received by the Feature
		            (fire and forget).
		        '400':
		          description: |-
		            The request could not be completed. The `thingId` either
		              * does not contain the mandatory namespace prefix (java package notation + `:` colon)
		              * does not conform to RFC-2396 (URI)
		          
		            Or at least one of the defined path parameters was invalid.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '401':
		          description: The request could not be completed due to missing authentication.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '403':
		          description: |-
		            The request could not be completed. Either
		            * due to a missing or invalid API Token.
		            * as the caller does not have `WRITE` permission on the resource message:/features/`featureId`/inbox/messages/`messageSubject`.
		          content:
		            application/json:
		              schema:
		                $ref: '#/components/schemas/AdvancedError'
		        '413':
		          $ref: '#/components/responses/messageTooLarge'
		      «IF !operation.params.empty»
		      requestBody:
		        $ref: '#/components/requestBodies/«fbProperty.type.name»«operation.name.toFirstUpper»Payload'
		      «ENDIF»
		  «ENDFOR»
		«ENDFOR»
		components:
		  schemas:
		    AdvancedError:
		      properties:
		        status:
		          type: integer
		          description: The HTTP status of the error
		        error:
		          type: string
		          description: The error code of the occurred exception
		        message:
		          type: string
		          description: The message of the error - what went wrong
		        description:
		          type: string
		          description: A description how to fix the error or more details
		        href:
		          type: string
		          description: A link to further information about the error and how to fix it
		      required:
		      - status
		      - error
		      - message
		    FeatureDefinition:
		      type: array
		      minItems: 1
		      uniqueItems: true
		      items:
		        type: string
		        description: "A single fully qualified identifier of a Feature Definition in the form 'namespace:name:version'"
		        pattern: ([_a-zA-Z0-9\-.]+):([_a-zA-Z0-9\-.]+):([_a-zA-Z0-9\-.]+)
		    «FOR fb : Utils.getReferencedFunctionBlocks(infomodel)»
		    «IF fb.functionblock.configuration !== null»
		    «FOR configurationProperty : fb.functionblock.configuration.properties»
		    «fb.name»«configurationProperty.name.toFirstUpper»ConfigurationValue:
		      «IF configurationProperty.type instanceof PrimitivePropertyType»
		      «wrapIfMultiple(getPrimitive((configurationProperty.type as PrimitivePropertyType).type).toString,configurationProperty.multiplicity)»
		      «ELSEIF configurationProperty.type instanceof ObjectPropertyType»
		      «wrapIfMultiple("$ref: '#/components/schemas/"+(configurationProperty.type as ObjectPropertyType).type.name+"'",configurationProperty.multiplicity)»
		      «ENDIF»
		    «ENDFOR»
		    «ENDIF»
		    «FOR operation : fb.functionblock.operations»
		    «IF !operation.params.empty»
		    «fb.name»«operation.name.toFirstUpper»Payload:
		      type: object
		      properties:
		        «FOR param : operation.params»
		        «param.name»:
		          «IF param.description !== null»description: «param.description»«ENDIF»
		          «IF param instanceof PrimitiveParam»
		          «wrapIfMultiple(getPrimitive((param as PrimitiveParam).type).toString,param.multiplicity)»
		          «ELSEIF param instanceof RefParam»
		          «wrapIfMultiple("$ref: '#/components/schemas/"+(param as RefParam).type.name+"'",param.multiplicity)»
		          «ENDIF»
		        «ENDFOR»
		    «ENDIF»
		    «ENDFOR»
		    «fb.name»Properties:
		      type: object
		      description: «fb.name» properties of «infomodel.name»
		      properties:
		        «IF fb.functionblock.status !== null && !fb.functionblock.status.properties.isEmpty»
		        status:
		          type: object
		          properties:
		            «FOR statusProperty : fb.functionblock.status.properties»
		            «statusProperty.name»:
		              «IF statusProperty.description !== null»description: «statusProperty.description»«ENDIF»
		              «IF statusProperty.type instanceof PrimitivePropertyType»
		              «wrapIfMultiple(getPrimitive((statusProperty.type as PrimitivePropertyType).type).toString,statusProperty.multiplicity)»
		              «ELSEIF statusProperty.type instanceof ObjectPropertyType»
		              «wrapIfMultiple("$ref: '#/components/schemas/"+(statusProperty.type as ObjectPropertyType).type.name+"'",statusProperty.multiplicity)»
		            «ENDIF»
		            «ENDFOR»
		          «Utils.calculateRequired(fb.functionblock.status.properties)»
		        «ENDIF»
		        «IF fb.functionblock.configuration !== null && !fb.functionblock.configuration.properties.isEmpty»
		        configuration:
		          type: object
		          properties:
		            «FOR configProperty : fb.functionblock.configuration.properties»
		            «configProperty.name»:
		              «IF configProperty.description !== null»description: «configProperty.description»«ENDIF»
		              «IF configProperty.type instanceof PrimitivePropertyType»
		              «wrapIfMultiple(getPrimitive((configProperty.type as PrimitivePropertyType).type).toString,configProperty.multiplicity)»
		              «ELSEIF configProperty.type instanceof ObjectPropertyType»
		              «wrapIfMultiple("$ref: '#/components/schemas/"+(configProperty.type as ObjectPropertyType).type.name+"'",configProperty.multiplicity)»
		            «ENDIF»
		            «ENDFOR»
		          «Utils.calculateRequired(fb.functionblock.configuration.properties)»
		        «ENDIF»
		    «fb.name»Feature:
		      type: object
		      properties:
		        definition:
		          $ref: '#/components/schemas/FeatureDefinition'
		          description: The Definition of this «fb.name» Feature
		        properties:
		          $ref: '#/components/schemas/«fb.name»Properties'
		          description: The Properties of this «fb.name» feature
		    «ENDFOR»
		    «infomodel.name»Features:
		      type: object
		      description: >-
		        List all Features of the «infomodel.name»
		      properties:
		        «FOR fbProperty : infomodel.properties»
		        «fbProperty.name»:
		          «IF fbProperty.description !== null»description: «fbProperty.description»«ENDIF»
		          $ref: '#/components/schemas/«fbProperty.type.name»Feature'
		        «ENDFOR»
		    «FOR entity : Utils.getReferencedEntities(infomodel)»
		    «entity.name»:
		      type: object
		      properties:
		        «FOR property : entity.properties»
		        «property.name»:
		          «IF property.description !== null»description: «property.description»«ENDIF»
		          «IF property.type instanceof PrimitivePropertyType»
		          «wrapIfMultiple(getPrimitive((property.type as PrimitivePropertyType).type).toString,property.multiplicity)»
		          «ELSEIF property.type instanceof ObjectPropertyType»
		          «wrapIfMultiple("$ref: '#/components/schemas/"+(property.type as ObjectPropertyType).type.name+"'",property.multiplicity)»
		          «ENDIF»
		        «ENDFOR»
		      «Utils.calculateRequired(entity.properties)»
		    «ENDFOR»
		    «FOR enumeration : Utils.getReferencedEnums(infomodel)»
		    «enumeration.name»:
		      type: string
		      enum: [«FOR literal: enumeration.enums SEPARATOR ','»«literal.name»«ENDFOR»]
		    «ENDFOR»
		  
		  requestBodies:
		    «FOR fb : Utils.getReferencedFunctionBlocks(infomodel)»
		    «IF fb.functionblock.configuration !== null»
		      «FOR configurationProperty : fb.functionblock.configuration.properties»
		        «fb.name»«configurationProperty.name.toFirstUpper»ConfigurationValue:
		          content:
		            application/json:
		              schema:
		                «IF configurationProperty.type instanceof PrimitivePropertyType»
		                «wrapIfMultiple(getPrimitive((configurationProperty.type as PrimitivePropertyType).type).toString,configurationProperty.multiplicity)»
		                «ELSEIF configurationProperty.type instanceof ObjectPropertyType»
		                «wrapIfMultiple("$ref: '#/components/schemas/"+(configurationProperty.type as ObjectPropertyType).type.name+"'",configurationProperty.multiplicity)»
		                «ENDIF»
		      «ENDFOR»
		    «ENDIF»
		    «FOR operation : fb.functionblock.operations»
		    «IF !operation.params.empty»
		    «fb.name»«operation.name.toFirstUpper»Payload:
		      content:
		        application/json:
		          schema:
		            type: object
		            properties:
		              «FOR param : operation.params»
		              «param.name»:
		                «IF param.description !== null»description: «param.description»«ENDIF»
		                «IF param instanceof PrimitiveParam»
		                «wrapIfMultiple(getPrimitive((param as PrimitiveParam).type).toString,param.multiplicity)»
		                «ELSEIF param instanceof RefParam»
		                «wrapIfMultiple("$ref: '#/components/schemas/"+(param as RefParam).type.name+"'",param.multiplicity)»
		                «ENDIF»
		              «ENDFOR»
		    «ENDIF»
		    «ENDFOR»
		  «ENDFOR»
		  responses:
		    entityTooLarge:
		      description: |-
		        The created or modified entity is larger than the accepted limit of 100 kB.
		      content:
		        application/json:
		          schema:
		            $ref: '#/components/schemas/AdvancedError'
		    messageTooLarge:
		      description: |-
		        The size of the send message is larger than the accepted limit of 250 kB.
		      content:
		        application/json:
		          schema:
		            $ref: '#/components/schemas/AdvancedError'
		    notModified:
		      description: >-
		        The (sub-)resource has not been modified. This happens when you specified a If-None-Match header which
		        matches the current ETag of the (sub-)resource.
		      headers:
		        ETag:
		          description: >-
		            The (current server-side) ETag for this (sub-)resource. For top-level resources it is in the format
		            "rev:[revision]", for sub-resources it has the format "hash:[calculated-hash]".
		          schema:
		            type: string
		    preconditionFailed:
		      description: >-
		        A precondition for reading or writing the (sub-)resource failed. This will happen for write requests, when you
		        specified an If-Match or If-None-Match header which fails the precondition check against the current ETag of
		        the (sub-)resource. For read requests, this error may only happen for a failing If-Match header. In case of a
		        failing If-None-Match header for a read request, status 304 will be returned instead.
		      headers:
		        ETag:
		          description: >-
		            The (current server-side) ETag for this (sub-)resource. For top-level resources it is in the format
		            "rev:[revision]", for sub-resources it has the format "hash:[calculated-hash]".
		          schema:
		            type: string
		      content:
		        application/json:
		          schema:
		            $ref: '#/components/schemas/AdvancedError'
		  parameters:
		    messageTimeoutParam:
		      name: timeout
		      in: query
		      description: |-
		          Contains an optional timeout (in seconds) of how long to wait for the message response and therefore block the
		          HTTP request. Default value (if omitted): 10 seconds. Maximum value: 60 seconds. A value of 0 seconds applies
		          fire and forget semantics for the message.
		      required: false
		      schema:
		        type: integer
		    thingIdPathParam:
		      name: thingId
		      in: path
		      description: |-
		        The ID of the Thing - has to:
		          * contain the mandatory namespace prefix (java package notation + `:` colon)
		          * conform to RFC-2396 (URI)
		      required: true
		      schema:
		        type: string
		  securitySchemes:
		    bearerAuth:
		      type: http
		      scheme: bearer
		      bearerFormat: JWT
		      description: |-
		        A JSON Web Token issued by a supported OAuth 2.0 Identity Provider.
		    thingsApiToken:
		      type: apiKey
		      description: |-
		        The API Token which associates the HTTP request with a specific IoT
		        Things service solution.
		      name: x-cr-api-token
		      in: header
		    BoschID:
		      type: oauth2
		      description: |-
		        Use either "OAuth2.0" with your Bosch-ID or the "Basic authentication"
		        below with a Demo user. Select the following checkbox in order to grant
		        Bosch IoT Things to access your Bosch-ID.
		      x-tokenName: id_token
		      flows:
		        authorizationCode:
		          authorizationUrl: >-
		            https://things.s-apps.de1.bosch-iot-cloud.com/oauth2/bosch-id/authorize
		          tokenUrl: 'https://things.s-apps.de1.bosch-iot-cloud.com/oauth2/bosch-id/token'
		          scopes:
		            openid: Access your Bosch-ID
		'''
	}
		
	def wrapIfMultiple(String type, boolean isArray) {
		'''
		«IF isArray»
		type: array
		items:
		  «type»
		«ELSE»
		«type»
		«ENDIF»
		'''
	}
	
	def getPrimitive(PrimitiveType primitiveType) {
		'''
		«IF primitiveType == PrimitiveType.BASE64_BINARY»
		type: string
		«ELSEIF primitiveType == PrimitiveType.BOOLEAN»
		type: boolean
		«ELSEIF primitiveType == PrimitiveType.BYTE»
		type: string
		«ELSEIF primitiveType == PrimitiveType.DATETIME»
		type: string
		«ELSEIF primitiveType == PrimitiveType.DOUBLE»
		type: number
		«ELSEIF primitiveType == PrimitiveType.FLOAT»
		type: number
		«ELSEIF primitiveType == PrimitiveType.INT»
		type: integer
		«ELSEIF primitiveType == PrimitiveType.LONG»
		type: number
		«ELSEIF primitiveType == PrimitiveType.SHORT»
		type: integer
		«ELSE»
		type: string
		«ENDIF»
		'''
	}
	
	def getJsonConstraint(ConstraintIntervalType type) {
		if(type == ConstraintIntervalType.STRLEN){
			return '''maxLength: '''
		} else if(type == ConstraintIntervalType.REGEX) {
			return '''pattern: '''
		} else if(type == ConstraintIntervalType.MIN) {
			return '''minimum: '''
		} else if(type == ConstraintIntervalType.MAX) {
			return '''maximum: '''
		} else if(type == ConstraintIntervalType.SCALING) {
			return '''multipleOf: '''
		} else if(type == ConstraintIntervalType.DEFAULT) {
			return '''default: '''
		}
		
		return null
	}	
	
}