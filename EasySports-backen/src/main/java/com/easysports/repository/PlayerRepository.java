package com.easysports.repository;

import com.easysports.model.Player;
import com.easysports.model.PlayerId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PlayerRepository extends JpaRepository<Player, PlayerId> {
}
