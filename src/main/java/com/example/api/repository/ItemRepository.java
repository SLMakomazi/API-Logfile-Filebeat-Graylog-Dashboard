package com.example.api.repository;

import com.example.api.model.Item;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Repository
public class ItemRepository {
    private final Map<Long, Item> items = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    public Item save(Item item) {
        if (item.getId() == null) {
            item.setId(idGenerator.getAndIncrement());
        }
        items.put(item.getId(), item);
        return item;
    }

    public Optional<Item> findById(Long id) {
        return Optional.ofNullable(items.get(id));
    }

    public List<Item> findAll() {
        return new ArrayList<>(items.values());
    }

    public Optional<Item> update(Long id, Item item) {
        if (items.containsKey(id)) {
            item.setId(id);
            items.put(id, item);
            return Optional.of(item);
        }
        return Optional.empty();
    }

    public boolean deleteById(Long id) {
        return items.remove(id) != null;
    }

    public boolean existsById(Long id) {
        return items.containsKey(id);
    }
}
