/*
 * Copyright 2016 Google LLC. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.cloud.tools.maven;

import java.io.File;
import java.nio.file.Path;
import org.apache.maven.model.Plugin;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.descriptor.PluginDescriptor;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.project.MavenProject;
import org.codehaus.plexus.util.xml.Xpp3Dom;

/** Abstract Mojo from which all goals inherit. */
public abstract class CloudSdkMojo extends AbstractMojo {

  /** Optional parameter to configure the location of the Google Cloud SDK. */
  @Parameter(property = "cloudSdkHome", required = false)
  private File cloudSdkHome;

  /** Optional parameter to configure the version of the Google Cloud SDK. */
  @Parameter(property = "cloudSdkVersion", required = false)
  private String cloudSdkVersion;

  /** Optional parameter to configure the key file used for gcloud authentication */
  @Parameter(property = "serviceAccountKeyFile", required = false)
  private File serviceAccountKeyFile;

  @Parameter(defaultValue = "${plugin}", readonly = true)
  private PluginDescriptor pluginDescriptor;

  @Parameter(defaultValue = "${project}", readonly = true)
  protected MavenProject mavenProject;

  private CloudSdkAppEngineFactory factory = new CloudSdkAppEngineFactory(this);

  public String getArtifactId() {
    return pluginDescriptor.getArtifactId();
  }

  public String getArtifactVersion() {
    return pluginDescriptor.getVersion();
  }

  public Path getCloudSdkHome() {
    return cloudSdkHome != null ? cloudSdkHome.toPath() : null;
  }

  public String getCloudSdkVersion() {
    return cloudSdkVersion;
  }

  public File getServiceAccountKeyFile() {
    return serviceAccountKeyFile;
  }

  public CloudSdkAppEngineFactory getAppEngineFactory() {
    return factory;
  }

  /**
   * Determines the Java compiler target version by inspecting the project's maven-compiler-plugin
   * configuration.
   *
   * @return The Java compiler target version.
   */
  public String getCompileTargetVersion() {
    // maven-plugin-compiler default is 1.5
    String javaVersion = "1.5";
    if (mavenProject != null) {
      // check the maven.compiler.target property first
      String mavenCompilerTargetProperty =
          mavenProject.getProperties().getProperty("maven.compiler.target");
      if (mavenCompilerTargetProperty != null) {
        javaVersion = mavenCompilerTargetProperty;
      } else {
        Plugin compilerPlugin =
            mavenProject.getPlugin("org.apache.maven.plugins:maven-compiler-plugin");
        if (compilerPlugin != null) {
          Xpp3Dom config = (Xpp3Dom) compilerPlugin.getConfiguration();
          if (config != null) {
            Xpp3Dom domVersion = config.getChild("target");
            if (domVersion != null) {
              javaVersion = domVersion.getValue();
            }
          }
        }
      }
    }
    return javaVersion;
  }

  protected String getPackaging() {
    return mavenProject.getPackaging();
  }
}
