package com.example.api.controller;

import com.example.api.model.Item;
import com.example.api.repository.ItemRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/items")
public class ItemController {
    private static final Logger logger = LoggerFactory.getLogger(ItemController.class);
    
    @Autowired
    private ItemRepository itemRepository;

    @PostMapping
    public ResponseEntity<Item> createItem(@RequestBody Item item) {
        Item savedItem = itemRepository.save(item);
        logger.info("Created item: {} with id={}", savedItem.getName(), savedItem.getId());
        return new ResponseEntity<>(savedItem, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<Item>> getAllItems() {
        List<Item> items = itemRepository.findAll();
        logger.info("Retrieved all items, count={}", items.size());
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Item> getItemById(@PathVariable Long id) {
        Optional<Item> item = itemRepository.findById(id);
        if (item.isPresent()) {
            logger.info("Retrieved item: {} with id={}", item.get().getName(), id);
            return ResponseEntity.ok(item.get());
        } else {
            logger.warn("Item not found with id={}", id);
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Item> updateItem(@PathVariable Long id, @RequestBody Item item) {
        Optional<Item> updatedItem = itemRepository.update(id, item);
        if (updatedItem.isPresent()) {
            logger.info("Updated item: {} with id={}", updatedItem.get().getName(), id);
            return ResponseEntity.ok(updatedItem.get());
        } else {
            logger.warn("Item not found for update with id={}", id);
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        boolean deleted = itemRepository.deleteById(id);
        if (deleted) {
            logger.info("Deleted item with id={}", id);
            return ResponseEntity.noContent().build();
        } else {
            logger.warn("Item not found for deletion with id={}", id);
            return ResponseEntity.notFound().build();
        }
    }
}
