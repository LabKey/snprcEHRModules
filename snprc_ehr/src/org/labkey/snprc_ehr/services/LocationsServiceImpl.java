package org.labkey.snprc_ehr.services;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.view.ViewContext;
import org.labkey.snprc_ehr.domain.Animal;
import org.labkey.snprc_ehr.domain.Location;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by lkacimi on 4/11/2017.
 */

/**
 * EHR schema doesn't offer a hierarchical view of SNPRC locations (@see CAMP)
 * <p>
 * This service is an attempt to recover the original hierarchy, though not backed by the underlying schema
 * <p>
 * Will be making a lot of assumptions, will fix any issues that might arise
 */
public class LocationsServiceImpl implements LocationsService
{
    private final ViewContext viewContext;

    public LocationsServiceImpl(ViewContext viewContext)
    {
        this.viewContext = viewContext;
    }

    /**
     * get root locations
     *
     * @return root locations as a list
     */
    @Override
    public List<Location> getRootLocations()
    {
        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo housingTable = userSchema.getTable("housing");
        SimpleFilter currentHousingRecordsFilter = new SimpleFilter();
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        Sort sort = new Sort();

        sort.insertSortColumn(FieldKey.fromString("room"), Sort.SortDirection.ASC);

        List<Location> locations = new TableSelector(housingTable, currentHousingRecordsFilter, sort).getArrayList(Location.class);

        List<Location> rootLocations = new ArrayList<>();
        List<Location> alreadySeenLocations = new ArrayList<Location>();

        for (Location location : locations)
        {
            if (this.isRootLocation(location))
            {
                if (!alreadySeenLocations.contains(location))
                {
                    rootLocations.add(location);
                    alreadySeenLocations.add(location);
                }
            }
            else
            {
                Location rootLocation = this.getRootLocation(location);
                if (!alreadySeenLocations.contains(rootLocation))
                {
                    rootLocations.add(rootLocation);
                    alreadySeenLocations.add(rootLocation);
                }
            }
        }

        rootLocations.sort((o1, o2) ->
        {
            try
            {
                double location1RoomAsDouble = Double.parseDouble(o1.getRoom());
                double location2RoomAsDouble = Double.parseDouble(o2.getRoom());
                if (location1RoomAsDouble == location2RoomAsDouble)
                {
                    return 0;
                }
                if (location1RoomAsDouble > location2RoomAsDouble)
                {
                    return 1;
                }
                return -1;


            }
            catch (Exception ex)
            {
                return 0;
            }


        });

        return rootLocations;
    }

    @Override
    public List<Location> getSubLocations(Location location)
    {
        if (!this.isRootLocation(location))
        {
            return Collections.emptyList();
        }

        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo housingTable = userSchema.getTable("housing");
        SimpleFilter currentHousingRecordsFilter = new SimpleFilter();
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("room"), location.getRoom(), CompareType.NEQ);
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("room"), location.getRoom().substring(0, location.getRoom().length() - 2), CompareType.STARTS_WITH);
        Sort sort = new Sort();
        sort.insertSortColumn(FieldKey.fromString("room"), Sort.SortDirection.ASC);
        List<Location> locations = new TableSelector(housingTable, currentHousingRecordsFilter, sort).getArrayList(Location.class);

        List<Location> subLocations = new ArrayList<>();
        List<Location> alreadySeenLocation = new ArrayList<>();

        for (Location l : locations)
        {
            if (!alreadySeenLocation.contains(l))
            {
                subLocations.add(l);
                alreadySeenLocation.add(l);
            }
        }
        return subLocations;

    }

    @Override
    public List<Animal> getAnimals(Location location)
    {

        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo housingTable = userSchema.getTable("housing");
        SimpleFilter currentHousingRecordsFilter = new SimpleFilter();
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("room"), location.getRoom(), CompareType.EQUAL);
        Sort sort = new Sort();
        sort.insertSortColumn(FieldKey.fromString("participantid"), Sort.SortDirection.ASC);

        List<Animal> animals = new TableSelector(housingTable, currentHousingRecordsFilter, sort).getArrayList(Animal.class);

        return animals;
    }


    /**
     * @param location
     * @return true if location is a root location, false otherwise
     */
    @Override
    public boolean isRootLocation(Location location)
    {
        return this.getRootLocation(location) == null;
    }


    @Override
    public boolean hasAnimals(Location location)
    {
        return !this.getAnimals(location).isEmpty();
    }

    @Override
    public Location getRootLocation(Location location)
    {
        if (location.getRoom() == null || location.getRoom().substring(location.getRoom().length() - 3).equals(".00"))
        {
            return null;
        }

        Location rootLocation = new Location();

        rootLocation.setRoom(location.getRoom().replaceAll("\\.[0-9]+", ".00"));


        return rootLocation;
    }

    @Override
    public boolean hasSubLocations(Location location)
    {
        return !this.getSubLocations(location).isEmpty();
    }
}
