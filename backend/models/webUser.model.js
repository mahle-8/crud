import { connect } from "../config/db/connectMysql.js";

class webUserModel {
  static async createUserWithWebUser({
    username,
    email,
    passwordHash,
    statusId,
    apiKey,
  }) {
    const [rows] = await connect.query(
      "CALL sp_create_user_with_web_user(?, ?, ?, ?)",
      [username, email, passwordHash, statusId]
    );
    return rows[0][0]; // { userId, apiUserId }
  }
  static async show() {
    const [rows] = await connect.query("SELECT * FROM `web_user` ORDER BY id");
    return rows[0];
  }
  static async showActiveWebUsers() {
    const [rows] = await connect.query("CALL sp_show_active_web_users()");
    return rows[0];
  }

  static async update(apiUserId, { username, passwordHash, isActive }) {
    const [results] = await connect.query(
      "CALL sp_update_user_and_web_user_by_web_id(?, ?, ?, ?)",
      [apiUserId, username, passwordHash, isActive]
    );

    return results[0][0]; // { updated_user_id: X } o null si no existía
  }

  static async delete(Id) {
    const [results] = await connect.query(
      "CALL sp_delete_web_user_and_user(?)",
      [Id]
    );
    return results[0][0].deletedUserId; // ID del usuario eliminado o null si no existe
  }

  static async findById(id) {
    const [rows] = await connect.query("SELECT * FROM web_user WHERE id = ?", [
      id,
    ]);
    return rows[0];
  }
  static async findByIdActive(userId) {
    const [rows] = await connect.query(
      "SELECT * FROM web_user WHERE user_id = ? AND is_active = 1 LIMIT 1",
      [userId]
    );

    return rows.length > 0 ? rows[0] : null;
  }
  static async updateSessionToken(userId, apiKey) {
    const [result] = await connect.query(
      "UPDATE api_user SET session_token = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?",
      [apiKey, userId]
    );
    return result.affectedRows > 0;
  }
  static async findByName(username) {
    const [rows] = await connect.query(
      "SELECT * FROM user WHERE username = ?",
      [username]
    );
    return rows[0]; // Devuelve el usuario completo si existe
  }
}
export default webUserModel;