/*
 * Copyright 2018 Google LLC. All Rights Reserved.
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

import com.google.cloud.tools.managedcloudsdk.BadCloudSdkVersionException;
import com.google.cloud.tools.managedcloudsdk.ManagedCloudSdk;
import com.google.cloud.tools.managedcloudsdk.UnsupportedOsException;
import com.google.cloud.tools.managedcloudsdk.Version;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class CloudSdkOperationsFactoryTest {

  @Test
  public void testNewManagedSdk_null() throws UnsupportedOsException, BadCloudSdkVersionException {
    // There's no way of testing for direct ManagedCloudSdk equality, so compare home paths
    ManagedCloudSdk sdk = new CloudSdkOperationsFactory().newManagedSdk(null);
    Assert.assertEquals(ManagedCloudSdk.newManagedSdk().getSdkHome(), sdk.getSdkHome());
  }

  @Test
  public void testNewManagedSdk_specific()
      throws UnsupportedOsException, BadCloudSdkVersionException {
    ManagedCloudSdk sdk = new CloudSdkOperationsFactory().newManagedSdk("191.0.0");
    Assert.assertEquals(
        ManagedCloudSdk.newManagedSdk(new Version("191.0.0")).getSdkHome(), sdk.getSdkHome());
  }

  @Test
  public void testNewDownloader() throws BadCloudSdkVersionException, UnsupportedOsException {
    CloudSdkDownloader expected =
        new CloudSdkDownloader(ManagedCloudSdk.newManagedSdk(new Version("191.0.0")));
    CloudSdkDownloader actual = new CloudSdkOperationsFactory().newDownloader("191.0.0");
    Assert.assertEquals(
        expected.getManagedCloudSdk().getSdkHome(), actual.getManagedCloudSdk().getSdkHome());
  }

  @Test
  public void testNewChecker() {
    CloudSdkChecker expected = new CloudSdkChecker("191.0.0");
    CloudSdkChecker actual = new CloudSdkOperationsFactory().newChecker("191.0.0");
    Assert.assertEquals(expected.getVersion(), actual.getVersion());
  }
}
