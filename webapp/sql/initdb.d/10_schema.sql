USE `isupipe`;

-- ユーザ (配信者、視聴者)
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `display_name` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  UNIQUE `uniq_user_name` (`name`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- プロフィール画像
CREATE TABLE `icons` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `image` LONGBLOB NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ユーザごとのカスタムテーマ
CREATE TABLE `themes` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `dark_mode` BOOLEAN NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブ配信
CREATE TABLE `livestreams` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` text NOT NULL,
  `playlist_url` VARCHAR(255) NOT NULL,
  `thumbnail_url` VARCHAR(255) NOT NULL,
  `start_at` BIGINT NOT NULL,
  `end_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブ配信予約枠
CREATE TABLE `reservation_slots` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `slot` BIGINT NOT NULL,
  `start_at` BIGINT NOT NULL,
  `end_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブストリームに付与される、サービスで定義されたタグ
CREATE TABLE `tags` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  UNIQUE `uniq_tag_name` (`name`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブ配信とタグの中間テーブル
CREATE TABLE `livestream_tags` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `livestream_id` BIGINT NOT NULL,
  `tag_id` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブ配信視聴履歴
CREATE TABLE `livestream_viewers_history` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブ配信に対するライブコメント
CREATE TABLE `livecomments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  `comment` VARCHAR(255) NOT NULL,
  `tip` BIGINT NOT NULL DEFAULT 0,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ユーザからのライブコメントのスパム報告
CREATE TABLE `livecomment_reports` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  `livecomment_id` BIGINT NOT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- 配信者からのNGワード登録
CREATE TABLE `ng_words` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  `word` VARCHAR(255) NOT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE INDEX ng_words_word ON ng_words(`word`);

-- ライブ配信に対するリアクション
CREATE TABLE `reactions` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  -- :innocent:, :tada:, etc...
  `emoji_name` VARCHAR(255) NOT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- インデックス
CREATE INDEX idx_icons_user_id ON icons (user_id);
CREATE INDEX idx_livecomment_reports_livecomment_id ON livecomment_reports (livecomment_id);
CREATE INDEX idx_livecomment_reports_livestream_id ON livecomment_reports (livestream_id);
CREATE INDEX idx_livecomment_reports_user_id ON livecomment_reports (user_id);
CREATE INDEX idx_livecomments_livestream_id ON livecomments (livestream_id);
CREATE INDEX idx_livecomments_user_id ON livecomments (user_id);
CREATE INDEX idx_livestream_tags_livestream_id ON livestream_tags (livestream_id);
CREATE INDEX idx_livestream_tags_tag_id ON livestream_tags (tag_id);
CREATE INDEX idx_livestream_viewers_history_livestream_id ON livestream_viewers_history (livestream_id);
CREATE INDEX idx_livestream_viewers_history_user_id ON livestream_viewers_history (user_id);
CREATE INDEX idx_livestreams_user_id ON livestreams (user_id);
CREATE INDEX idx_ng_words_livestream_id ON ng_words (livestream_id);
CREATE INDEX idx_ng_words_user_id ON ng_words (user_id);
CREATE INDEX idx_reactions_livestream_id ON reactions (livestream_id);
CREATE INDEX idx_reactions_user_id ON reactions (user_id);
CREATE INDEX idx_themes_user_id ON themes (user_id);

-- ハッシュ
ALTER TABLE icons ADD COLUMN image_hash CHAR(64) NOT NULL DEFAULT '';

DELIMITER //

CREATE TRIGGER before_insert_image_hash
BEFORE INSERT ON icons
FOR EACH ROW
BEGIN
    SET NEW.image_hash = SHA2(NEW.image, 256);
END; //

CREATE TRIGGER before_update_image_hash
BEFORE UPDATE ON icons
FOR EACH ROW
BEGIN
    IF NEW.image != OLD.image THEN
        SET NEW.image_hash = SHA2(NEW.image, 256);
    END IF;
END; //

DELIMITER ;
