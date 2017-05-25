package org.labkey.snprc_ehr.services;

import org.labkey.snprc_ehr.domain.Animal;
import org.labkey.snprc_ehr.domain.Location;

import java.util.List;

/**
 * Created by lkacimi on 4/11/2017.
 */
public interface LocationsService
{
    List<Location> getRootLocations();

    List<Location> getSubLocations(Location location);

    boolean hasSubLocations(Location location);

    List<Animal> getAnimals(Location location);

    boolean isRootLocation(Location location);

    boolean hasAnimals(Location location);

    Location getRootLocation(Location location);

    List<Location> getLocationsPath(Animal animal);
}
