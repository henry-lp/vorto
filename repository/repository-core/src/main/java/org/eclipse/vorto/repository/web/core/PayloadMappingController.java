/**
 * Copyright (c) 2020 Contributors to the Eclipse Foundation
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
package org.eclipse.vorto.repository.web.core;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.io.IOUtils;
import org.eclipse.vorto.mapping.engine.decoder.CSVDeserializer;
import org.eclipse.vorto.mapping.engine.decoder.IPayloadDeserializer;
import org.eclipse.vorto.mapping.engine.decoder.JSONDeserializer;
import org.eclipse.vorto.mapping.engine.model.spec.IMappingSpecification;
import org.eclipse.vorto.mapping.engine.model.spec.MappingSpecification;
import org.eclipse.vorto.model.ModelId;
import org.eclipse.vorto.model.runtime.InfomodelValue;
import org.eclipse.vorto.repository.core.IUserContext;
import org.eclipse.vorto.repository.core.ModelAlreadyExistsException;
import org.eclipse.vorto.repository.core.ModelInfo;
import org.eclipse.vorto.repository.core.ModelNotFoundException;
import org.eclipse.vorto.repository.core.impl.UserContext;
import org.eclipse.vorto.repository.domain.Namespace;
import org.eclipse.vorto.repository.mapping.IPayloadMappingService;
import org.eclipse.vorto.repository.repositories.NamespaceRepository;
import org.eclipse.vorto.repository.web.AbstractRepositoryController;
import org.eclipse.vorto.repository.web.core.dto.mapping.TestContentType;
import org.eclipse.vorto.repository.web.core.dto.mapping.TestMappingRequest;
import org.eclipse.vorto.repository.web.core.dto.mapping.TestMappingResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/rest/mappings/specifications")
public class PayloadMappingController extends AbstractRepositoryController {

  @Autowired
  private IPayloadMappingService mappingService;

  @Autowired
  private NamespaceRepository namespaceRepository;

  private static final String ATTACHMENT_FILENAME = "attachment; filename = ";
  private static final String APPLICATION_OCTET_STREAM = "application/octet-stream";
  private static final String CONTENT_DISPOSITION = "content-disposition";

  private static final IPayloadDeserializer CSV_DESERIALIZER = new CSVDeserializer();
  private static final IPayloadDeserializer JSON_DESERIALIZER = new JSONDeserializer();

  @GetMapping(value = "/{modelId:.+}/mappingId")
  @PreAuthorize("hasAuthority('model_viewer')")
  public ResponseEntity<Map<String, Object>> getMappingIdForModelId(
      @PathVariable final String modelId) {
    Optional<ModelInfo> mappingId = mappingService
        .resolveMappingIdForModelId(ModelId.fromPrettyFormat(modelId));
    if (mappingId.isPresent()) {
      Map<String, Object> result = new HashMap<>(1);
      result.put("mappingId", mappingId.get().getId().getPrettyFormat());
      return new ResponseEntity<>(result, HttpStatus.ACCEPTED);
    } else {
      throw new ModelNotFoundException("Cannot find mapping for modelId");
    }
  }

  @GetMapping(value = "/{modelId:.+}")
  @PreAuthorize("hasAuthority('model_viewer')")
  public IMappingSpecification getMappingSpecification(@PathVariable final String modelId) {
    return mappingService.getOrCreateSpecification(ModelId.fromPrettyFormat(modelId));
  }

  @RequestMapping(value = "/{modelId:.+}/exists", method = RequestMethod.GET)
  @PreAuthorize("hasAuthority('model_viewer')")
  public Map<String, Object> exists(@PathVariable final String modelId) {
    Map<String, Object> result = new HashMap<>();
    result.put("exists", mappingService.exists(ModelId.fromPrettyFormat(modelId)));
    return result;
  }

  @PutMapping(value = "/test")
  @PreAuthorize("hasAuthority('model_viewer')")
  public TestMappingResponse testMapping(@RequestBody TestMappingRequest testRequest)
      throws Exception {

    Object content = null;
    if (testRequest.getContentType().equals(TestContentType.csv)) {
      content = CSV_DESERIALIZER.deserialize(testRequest.getContent());
    } else {
      content = JSON_DESERIALIZER.deserialize(testRequest.getContent());
    }

    InfomodelValue mappedOutput = mappingService.runTest(testRequest.getSpecification(), content);

    TestMappingResponse response = new TestMappingResponse();
    response.setCanonical(new ObjectMapper().writeValueAsString(mappedOutput.serialize()));
    response.setDitto(new Gson().toJson(
        org.eclipse.vorto.mapping.targetplatform.ditto.TwinPayloadFactory
            .toDittoProtocol(mappedOutput, "com.acme:4711")));
    response.setAwsiot(new Gson().toJson(
        org.eclipse.vorto.mapping.targetplatform.awsiot.TwinPayloadFactory
            .toShadowUpdateRequest(mappedOutput)));
    response.setReport(mappedOutput.validate());
    return response;
  }

  @PutMapping(value = "/{modelId:.+}")
  @PreAuthorize("hasAuthority('model_creator')")
  public void saveMappingSpecification(@RequestBody MappingSpecification mappingSpecification,
      @PathVariable String modelId) {
    Namespace namespace = namespaceRepository
        .findByName(ModelId.fromPrettyFormat(modelId).getNamespace());
    IUserContext userContext;
    if (namespace != null) {
      userContext = UserContext
          .user(SecurityContextHolder.getContext().getAuthentication(), namespace.getWorkspaceId());
    } else {
      userContext = UserContext.user(SecurityContextHolder.getContext().getAuthentication());
    }
    this.mappingService.saveSpecification(mappingSpecification, userContext);
  }

  @ApiResponses(
      value = {@ApiResponse(code = 200, message = "Successful download of mapping specification"),
          @ApiResponse(code = 400, message = "Wrong input"),
          @ApiResponse(code = 404, message = "Model not found")})
  @PreAuthorize("hasAuthority('model_viewer')")
  @GetMapping(value = "/{modelId:.+}/file")
  public void downloadModelById(@PathVariable final String modelId,
      final HttpServletResponse response) {
    Objects.requireNonNull(modelId, "modelId must not be null");

    final ModelId modelID = ModelId.fromPrettyFormat(modelId);

    response.setHeader(CONTENT_DISPOSITION, ATTACHMENT_FILENAME + modelID.getNamespace() + "_"
        + modelID.getName() + "_" + modelID.getVersion() + "-mappingspec.json");
    response.setContentType(APPLICATION_OCTET_STREAM);
    try {
      MappingSpecification spec = (MappingSpecification) this.mappingService
          .getOrCreateSpecification(modelID);
      ObjectMapper mapper = new ObjectMapper();
      IOUtils.copy(
          new ByteArrayInputStream(mapper.writerWithDefaultPrettyPrinter().writeValueAsBytes(spec)),
          response.getOutputStream());
      response.flushBuffer();
    } catch (Exception e) {
      throw new RuntimeException("Error copying file.", e);
    }
  }

  @ResponseStatus(value = HttpStatus.CONFLICT, reason = "Mapping Specification already exists.")
  // 409
  @ExceptionHandler(ModelAlreadyExistsException.class)
  public void modelExists(final ModelAlreadyExistsException ex) {
    // do logging
  }
}
