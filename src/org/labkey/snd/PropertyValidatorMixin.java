package org.labkey.snd;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Configures the fields that are not returned when serializing a GWTPropertyValidator.
 * Ideally we would just add the @JsonIgnore annotations to GWTPropertyValidator directly,
 * but the GWT compiler would need to have jackson on the classpath which isn't
 * necessary.
 */
@JsonIgnoreProperties({
        "type"  // Done outside jackson
})
public abstract class PropertyValidatorMixin
{
}
