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
package org.eclipse.vorto.repository.domain;

import com.google.common.collect.Lists;
import java.util.Arrays;
import java.util.List;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import org.eclipse.vorto.model.ModelId;
import org.hibernate.annotations.NaturalId;

@Entity
@Table(name = "namespace")
public class Namespace {

  public static final String PRIVATE_NAMESPACE_PREFIX = "vorto.private.";

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "workspace_id")
  private String workspaceId;

  @NaturalId
  private String name;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getWorkspaceId() {
    return workspaceId;
  }

  public void setWorkspaceId(String workspaceId) {
    this.workspaceId = workspaceId;
  }

  public boolean owns(ModelId modelId) {
    return in(getName(), components(modelId.getNamespace()));
  }

  public boolean owns(String namespace) {
    return in(getName(), components(namespace));
  }

  public boolean isInConflictWith(String namespace) {
    return in(namespace, components(getName())) || in(getName(), components(namespace));
  }

  private String[] components(String namespace) {
    String[] breakdown = namespace.split("\\.");
    List<String> components = Lists.newArrayList();
    for (int i = 1; i <= breakdown.length; i++) {
      components.add(String.join(".", Arrays.copyOfRange(breakdown, 0, i)));
    }
    return components.toArray(new String[components.size()]);
  }

  private boolean in(String str, String[] strings) {
    return Arrays.stream(strings).anyMatch(str::equals);
  }
}
