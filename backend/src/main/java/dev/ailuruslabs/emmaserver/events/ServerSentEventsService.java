package dev.ailuruslabs.emmaserver.events;

import dev.ailuruslabs.emmaserver.incidents.Incident;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class ServerSentEventsService {

    private final List<SseEmitter> emitters = new CopyOnWriteArrayList<>();

    public SseEmitter subscribe() {
        SseEmitter emitter = new SseEmitter(30 * 60 * 1000L);

        emitters.add(emitter);

        emitter.onCompletion(() -> emitters.remove(emitter));
        emitter.onTimeout((() -> emitters.remove(emitter)));

        return emitter;
    }

    public void broadcastIncident(Incident incident) {
        for (var emitter : emitters) {
            try {
                emitter.send(
                    SseEmitter.event()
                        .name("incident-report")
                        .data(incident)
                );
            } catch (IOException e) {
                emitters.remove(emitter);
            }
        }
    }

}
