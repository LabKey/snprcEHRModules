package org.labkey.snprc_ehr.services;

import org.json.JSONObject;
import org.labkey.snprc_ehr.domain.State;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 4/12/2017.
 */
public class StatesService
{
    private Map states = new LinkedHashMap<>();

    public StatesService()
    {
        states.put("", "N/A");
        states.put("GL", "International");
        states.put("AK", "Alaska");
        states.put("AL", "Alabama");
        states.put("AR", "Akansas");
        states.put("AZ", "Arizona");
        states.put("CA", "California");
        states.put("CO", "Colorado");
        states.put("CT", "Connecticut");
        states.put("DC", "District Of Columbia");
        states.put("DE", "Delaware");
        states.put("FL", "Florida");
        states.put("GA", "Georgia");
        states.put("HI", "Hawaii");
        states.put("IA", "Iowa");
        states.put("ID", "Idaho");
        states.put("IL", "Illinois");
        states.put("IN", "Indiana");
        states.put("KS", "Kansas");
        states.put("KY", "Kentucky");
        states.put("LA", "Louisiana");
        states.put("MA", "Massachusetts");
        states.put("MD", "Maryland");
        states.put("ME", "Maine");
        states.put("MI", "Michigan");
        states.put("MN", "Minnesota");
        states.put("MO", "Missouri");
        states.put("MS", "Mississsippi");
        states.put("MT", "Montana");
        states.put("NC", "North Carolina");
        states.put("ND", "North Dakota");
        states.put("NE", "Nebraska");
        states.put("NH", "New Hampshire");
        states.put("NJ", "New Jersey");
        states.put("NM", "New Mexico");
        states.put("NV", "Nevada");
        states.put("NY", "New York");
        states.put("OH", "Ohio");
        states.put("OK", "Oklahoma");
        states.put("OR", "Oregon");
        states.put("PA", "Pennsylvania");
        states.put("RI", "Rhode Island");
        states.put("SC", "South Carolina");
        states.put("SD", "South Dakota");
        states.put("TN", "Tennessee");
        states.put("TX", "Texas");
        states.put("UT", "Utah");
        states.put("VA", "Virginia");
        states.put("VT", "Vermont");
        states.put("WA", "Washington");
        states.put("WI", "Wisconsin");
        states.put("WV", "West Virginia");
        states.put("WY", "Wyoming");
        states.put("GU", "Guam");
        states.put("VI", "Virgin Islands");
        states.put("PR", "Puerto Rico");
        states.put("AE", "Armed forces - Europe");
        states.put("AA", "Armed forces - America");
        states.put("AP", "Armed forces - Pacific");

        // Load Canada Codes.
        states.put("AB", "Alberta");
        states.put("BC", "British Columbia");
        states.put("MB", "Manitoba");
        states.put("NB", "New Brunswick");
        states.put("NL", "Newfoundland and Labrador");
        states.put("NT", "Northwest Territories");
        states.put("NS", "Nova Scotia");
        states.put("NU", "Nunavut");
        states.put("ON", "Ontario");
        states.put("PE", "Prince Edward Island");
        states.put("QC", "Quebec");
        states.put("SK", "Saskatchewan");
        states.put("YT", "Yukon");

        // Load Mexico Codes.
        states.put("AGU", "Aguascalientes");
        states.put("BCN", "Baja California");
        states.put("BCS", "Baja California Sur");
        states.put("CAM", "Campeche");
        states.put("CHP", "Chiapas");
        states.put("CHH", "Chihuahua");
        states.put("COA", "Coahuila");
        states.put("COL", "Colima");
        states.put("DIF", "Distrito Federal");
        states.put("DUR", "Durango");
        states.put("GUA", "Guanajuato");
        states.put("GRO", "Guerrero");
        states.put("HID", "Hidalgo");
        states.put("JAL", "Jalisco");
        states.put("MEX", "Mexico");
        states.put("MIC", "Michoacán");
        states.put("MOR", "Morelos");
        states.put("NAY", "Nayarit");
        states.put("NLE", "Nuevo Leon");
        states.put("OAX", "Oaxaca");
        states.put("PUE", "Puebla");
        states.put("QUE", "Queretaro");
        states.put("ROO", "Quintana Roo");
        states.put("SLP", "San Luis Potosi");
        states.put("SIN", "Sinaloa");
        states.put("SON", "Sonora");
        states.put("TAB", "Tabasco");
        states.put("TAM", "Tamaulipas");
        states.put("TLA", "Tlaxcala");
        states.put("VER", "Veracruz");
        states.put("YUC", "Yucatan");
        states.put("ZAC", "Zacatecas");

    }

    public List<JSONObject> getStates()
    {
        List<JSONObject> states = new ArrayList<>();
        Iterator it = this.states.entrySet().iterator();
        while (it.hasNext())
        {
            Map.Entry pair = (Map.Entry) it.next();
            states.add(new State((String) pair.getKey(), (String) pair.getValue()).toJSON());
        }
        return states;
    }


}
