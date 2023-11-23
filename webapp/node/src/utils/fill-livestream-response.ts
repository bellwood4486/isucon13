import { PoolConnection, RowDataPacket } from 'mysql2/promise'
import {
  LivestreamTagsModel,
  LivestreamsModel,
  TagsModel,
  UserModel,
} from '../types/models'
import { UserResponse, fillUserResponse } from './fill-user-response'
import { throwErrorWith } from './throw-error-with'

export interface LivestreamResponse {
  id: number
  owner: UserResponse
  title: string
  tags: { id: number; name: string }[]
  description: string
  playlist_url: string
  thumbnail_url: string
  start_at: number
  end_at: number
}

export const fillLivestreamResponse = async (
  conn: PoolConnection,
  livestream: LivestreamsModel,
  fallbackUserIcon: Readonly<ArrayBuffer>,
) => {
  const [[user]] = await conn
    .query<(UserModel & RowDataPacket)[]>('SELECT * FROM users WHERE id = ?', [
      livestream.user_id,
    ])
    .catch(throwErrorWith('failed to get user'))
  if (!user) throw new Error('not found user that has the given id')

  const userResponse = await fillUserResponse(conn, user, fallbackUserIcon)

  const [livestreamTags] = await conn
    .query<(LivestreamTagsModel & RowDataPacket)[]>(
      'SELECT * FROM livestream_tags WHERE livestream_id = ?',
      [livestream.id],
    )
    .catch(throwErrorWith('failed to get livestream tags'))

  const tags: TagsModel[] = []
  for (const livestreamTag of livestreamTags) {
    const [[tag]] = await conn
      .query<(TagsModel & RowDataPacket)[]>('SELECT * FROM tags WHERE id = ?', [
        livestreamTag.tag_id,
      ])
      .catch(throwErrorWith('failed to get tag'))
    tags.push(tag)
  }

  return {
    id: livestream.id,
    owner: userResponse,
    title: livestream.title,
    tags: tags.map((tag) => ({ id: tag.id, name: tag.name })),
    description: livestream.description,
    playlist_url: livestream.playlist_url,
    thumbnail_url: livestream.thumbnail_url,
    start_at: livestream.start_at,
    end_at: livestream.end_at,
  } satisfies LivestreamResponse
}
