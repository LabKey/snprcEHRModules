/*
 * Copyright (c) 2017 LabKey Corporation
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
package org.labkey.snprc_ehr.domain;

import java.util.List;

/**
 * Created by lkacimi on 5/25/2017.
 */
public class AnimalNodePath
{
    /**
     * Path to location, starting from a root location
     */
    private List<Node> _nodes;

    private String animalId;

    public List<Node> getLocations()
    {
        return _nodes;
    }

    public void setLocations(List<Node> nodes)
    {
        this._nodes = nodes;
    }

    public String getAnimalId()
    {
        return animalId;
    }

    public void setAnimalId(String animalId)
    {
        this.animalId = animalId;
    }
}
