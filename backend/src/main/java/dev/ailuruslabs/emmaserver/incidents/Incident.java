package dev.ailuruslabs.emmaserver.incidents;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.locationtech.jts.geom.Point;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "incidents")
public class Incident {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private UUID reporterId;

    @Column(columnDefinition = "geography(Point, 4326)")
    private Point location;

    private String title;
    private String description;

    @Enumerated(EnumType.STRING)
    private IncidentType type;

    @CreationTimestamp
    @Column(updatable = false)
    private ZonedDateTime reportedAt;

    @UpdateTimestamp
    private ZonedDateTime updatedAt;

    public Incident(UUID reporterId, Point location, String title, String description, IncidentType type) {
        this.reporterId = reporterId;
        this.location = location;
        this.title = title;
        this.description = description;
        this.type = type;
    }

    public Incident() {}

    public Long getId() {
        return id;
    }

    public UUID getReporterId() {
        return reporterId;
    }

    public Point getLocation() {
        return location;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public IncidentType getType() {
        return type;
    }

    public ZonedDateTime getReportedAt() {
        return reportedAt;
    }

    public ZonedDateTime getUpdatedAt() {
        return updatedAt;
    }
}
