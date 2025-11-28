package com.easysports.model;

import java.io.Serializable;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class PlayerId implements Serializable {
    private Long usuario; // Corresponde al nombre del campo 'usuario' en la entidad Player
    private Long equipo;  // Corresponde al nombre del campo 'equipo' en la entidad Player
}
