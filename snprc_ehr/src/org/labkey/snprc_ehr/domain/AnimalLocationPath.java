package org.labkey.snprc_ehr.domain;

import java.util.List;

/**
 * Created by lkacimi on 5/25/2017.
 */
public class AnimalLocationPath
{
    /**
     * Path to location, starting from a root location
     */
    private List<Location> locations;

    private String animalId;

    public List<Location> getLocations()
    {
        return locations;
    }

    public void setLocations(List<Location> locations)
    {
        this.locations = locations;
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
