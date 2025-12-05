package com.easysports.config;

import com.easysports.enums.Deporte;
import com.easysports.enums.MatchStatus;
import com.easysports.enums.MatchType;
import com.easysports.enums.Sexo;
import com.easysports.model.Match;
import com.easysports.model.Team;
import com.easysports.model.User;
import com.easysports.repository.MatchRepository;
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Component
@RequiredArgsConstructor
// @Profile("!test") // Comentar o descomentar según se quiera ejecutar en tests
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final MatchRepository matchRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        seedUsers();
        seedTeams();
        seedMatches();
    }

    private void seedUsers() {
        if (userRepository.findByEmail("use@gmail.com").isEmpty()) {
            User user1 = User.builder()
                    .email("use@gmail.com")
                    .password(passwordEncoder.encode("12345"))
                    .nombreCompleto("Juan Pérez")
                    .sexo(Sexo.HOMBRE)
                    .edadAnios(25)
                    .edadMeses(6)
                    .esLeagueManager(false)
                    .posicionPreferida("Delantero")
                    .puntuacion(new BigDecimal("4.5"))
                    .avatarUrl("https://i.pravatar.cc/150?u=user1")
                    .build();
            userRepository.save(user1);
            System.out.println("Usuario use@gmail.com creado.");
        }

        if (userRepository.findByEmail("user2@easysports.com").isEmpty()) {
            User user2 = User.builder()
                    .email("user2@easysports.com")
                    .password(passwordEncoder.encode("123456"))
                    .nombreCompleto("Maria Lopez")
                    .sexo(Sexo.MUJER)
                    .edadAnios(22)
                    .edadMeses(3)
                    .esLeagueManager(false)
                    .posicionPreferida("Defensa")
                    .puntuacion(new BigDecimal("4.8"))
                    .avatarUrl("https://i.pravatar.cc/150?u=user2")
                    .build();
            userRepository.save(user2);
            System.out.println("Usuario user2 creado.");
        }

        if (userRepository.findByEmail("admin@easysports.com").isEmpty()) {
            User admin = User.builder()
                    .email("admin@easysports.com")
                    .password(passwordEncoder.encode("admin123"))
                    .nombreCompleto("Admin User")
                    .sexo(Sexo.OTRO)
                    .edadAnios(30)
                    .edadMeses(0)
                    .esLeagueManager(true)
                    .puntuacion(new BigDecimal("5.0"))
                    .build();
            userRepository.save(admin);
            System.out.println("Usuario admin creado.");
        }
    }

    private void seedTeams() {
        if (teamRepository.findByNombre("Los Rayos").isPresent()) {
            return; // Ya existen equipos
        }
        
        User capitan1 = userRepository.findByEmail("use@gmail.com").orElseThrow();
        User capitan2 = userRepository.findByEmail("user2@easysports.com").orElseThrow();

        Team team1 = Team.builder()
                .nombre("Los Rayos")
                .tipoDeporte(Deporte.FUTBOL)
                .capitan(capitan1)
                .partidosGanados(5)
                .build();

        Team team2 = Team.builder()
                .nombre("Las Estrellas")
                .tipoDeporte(Deporte.FUTBOL)
                .capitan(capitan2)
                .partidosGanados(3)
                .build();

        teamRepository.save(team1);
        teamRepository.save(team2);
        
        System.out.println("Equipos creados exitosamente.");
    }

    private void seedMatches() {
        if (matchRepository.count() > 0) {
            return;
        }

        User creador = userRepository.findByEmail("use@gmail.com").orElseThrow();
        Team local = teamRepository.findByNombre("Los Rayos").get();
        Team visitante = teamRepository.findByNombre("Las Estrellas").get();

        // Partido Formal
        Match match1 = new Match();
        match1.setCodigo(UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        match1.setDeporte(Deporte.FUTBOL);
        match1.setTipo(MatchType.FORMAL);
        match1.setEstado(MatchStatus.ABIERTO);
        match1.setFechaProgramada(LocalDateTime.now().plusDays(2));
        match1.setCreador(creador);
        match1.setEquipoLocal(local);
        match1.setEquipoVisitante(visitante);
        match1.setNombreCanchaTexto("Estadio Central");
        match1.setMaxJugadores(22);
        match1.setJugadoresActuales(15);

        // Partido Casual
        Match match2 = new Match();
        match2.setCodigo(UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        match2.setDeporte(Deporte.BASKET);
        match2.setTipo(MatchType.CASUAL);
        match2.setEstado(MatchStatus.ABIERTO);
        match2.setFechaProgramada(LocalDateTime.now().plusDays(1));
        match2.setCreador(creador);
        match2.setNombreCanchaTexto("Cancha del Parque");
        match2.setMaxJugadores(10);
        match2.setJugadoresActuales(4);

        matchRepository.save(match1);
        matchRepository.save(match2);
        
        System.out.println("Partidos creados exitosamente.");
    }
}
