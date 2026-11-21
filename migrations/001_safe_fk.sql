-- Phase 1: 毫秒级上约束，不扫描历史大表
ALTER TABLE orders
  ADD CONSTRAINT fk_orders_merchant
  FOREIGN KEY (merchant_id) REFERENCES merchants(id) NOT VALID;

-- Phase 2: 在线异步校验历史数据，不阻塞业务读写
ALTER TABLE orders VALIDATE CONSTRAINT fk_orders_merchant;
