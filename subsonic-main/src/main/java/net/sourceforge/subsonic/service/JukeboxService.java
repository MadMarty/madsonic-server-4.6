/*
 This file is part of Subsonic.

 Subsonic is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Subsonic is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Subsonic.  If not, see <http://www.gnu.org/licenses/>.

 Copyright 2009 (C) Sindre Mehus
 */
package net.sourceforge.subsonic.service;

import net.sourceforge.subsonic.Logger;
import net.sourceforge.subsonic.domain.MusicFile;
import net.sourceforge.subsonic.domain.Player;
import net.sourceforge.subsonic.domain.Playlist;
import net.sourceforge.subsonic.domain.Transcoding;
import net.sourceforge.subsonic.domain.TransferStatus;
import net.sourceforge.subsonic.domain.User;
import net.sourceforge.subsonic.domain.VideoTranscodingSettings;
import net.sourceforge.subsonic.service.jukebox.AudioPlayer;
import net.sourceforge.subsonic.util.FileUtil;
import org.apache.commons.io.IOUtils;

import java.io.InputStream;

import static net.sourceforge.subsonic.service.jukebox.AudioPlayer.State.EOM;

/**
 * Plays music on the local audio device.
 *
 * @author Sindre Mehus
 */
public class JukeboxService implements AudioPlayer.Listener {

    private static final Logger LOG = Logger.getLogger(JukeboxService.class);

    private AudioPlayer audioPlayer;
    private TranscodingService transcodingService;
    private AudioScrobblerService audioScrobblerService;
    private StatusService statusService;
    private SettingsService settingsService;
    private MusicInfoService musicInfoService;
    private SecurityService securityService;

    private Player player;
    private TransferStatus status;
    private MusicFile currentPlayingFile;
    private float gain = 0.5f;
    private int offset;

    /**
     * Updates the jukebox by starting or pausing playback on the local audio device.
     *
     * @param player The player in question.
     * @param offset Start playing after this many seconds into the track.
     */
    public synchronized void updateJukebox(Player player, int offset) throws Exception {
        User user = securityService.getUserByName(player.getUsername());
        if (!user.isJukeboxRole()) {
            LOG.warn(user.getUsername() + " is not authorized for jukebox playback.");
            return;
        }

        if (player.getPlaylist().getStatus() == Playlist.Status.PLAYING) {
            this.player = player;
            play(player.getPlaylist().getCurrentFile(), offset);
        } else {
            if (audioPlayer != null) {
                audioPlayer.pause();
            }
        }
    }

    private synchronized void play(MusicFile file, int offset) {
        InputStream in = null;
        try {

            // Resume if possible.
            boolean sameFile = file != null && file.equals(currentPlayingFile);
            boolean paused = audioPlayer != null && audioPlayer.getState() == AudioPlayer.State.PAUSED;
            if (sameFile && paused && offset == 0) {
                audioPlayer.play();
            } else {
                this.offset = offset;
                if (audioPlayer != null) {
                    audioPlayer.close();
                    if (currentPlayingFile != null) {
                        onSongEnd(currentPlayingFile);
                    }
                }

                if (file != null) {
                    TranscodingService.Parameters parameters = new TranscodingService.Parameters(file, new VideoTranscodingSettings(0, 0, offset));
                    String command = settingsService.getJukeboxCommand();
                    parameters.setTranscoding(new Transcoding(null, null, null, null, command, null, null, false));
                    in = transcodingService.getTranscodedInputStream(parameters);
                    audioPlayer = new AudioPlayer(in, this);
                    audioPlayer.setGain(gain);
                    audioPlayer.play();
                    onSongStart(file);
                }
            }

            currentPlayingFile = file;

        } catch (Exception x) {
            LOG.error("Error in jukebox: " + x, x);
            IOUtils.closeQuietly(in);
        }
    }

    public synchronized void stateChanged(AudioPlayer audioPlayer, AudioPlayer.State state) {
        if (state == EOM) {
            player.getPlaylist().next();
            play(player.getPlaylist().getCurrentFile(), 0);
        }
    }

    public synchronized float getGain() {
        return gain;
    }

    public synchronized int getPosition() {
        return audioPlayer == null ? 0 : offset + audioPlayer.getPosition();
    }

    /**
     * Returns the player which currently uses the jukebox.
     *
     * @return The player, may be {@code null}.
     */
    public Player getPlayer() {
        return player;
    }

    private void onSongStart(MusicFile file) {
        LOG.info(player.getUsername() + " starting jukebox for \"" + FileUtil.getShortPath(file.getFile()) + "\"");
        status = statusService.createStreamStatus(player);
        status.setFile(file.getFile());
        status.addBytesTransfered(file.length());
        updateStatistics(file);
        scrobble(file, false);
    }

    private void onSongEnd(MusicFile file) {
        LOG.info(player.getUsername() + " stopping jukebox for \"" + FileUtil.getShortPath(file.getFile()) + "\"");
        if (status != null) {
            statusService.removeStreamStatus(status);
        }
        scrobble(file, true);
    }

    private void updateStatistics(MusicFile file) {
        try {
            MusicFile folder = file.getParent();
            if (!folder.isRoot()) {
                musicInfoService.incrementPlayCount(folder);
            }
        } catch (Exception x) {
            LOG.warn("Failed to update statistics for " + file, x);
        }
    }

    private void scrobble(MusicFile file, boolean submission) {
        if (player.getClientId() == null) {  // Don't scrobble REST players.
            audioScrobblerService.register(file, player.getUsername(), submission);
        }
    }

    public synchronized void setGain(float gain) {
        this.gain = gain;
        if (audioPlayer != null) {
            audioPlayer.setGain(gain);
        }
    }

    public void setTranscodingService(TranscodingService transcodingService) {
        this.transcodingService = transcodingService;
    }

    public void setAudioScrobblerService(AudioScrobblerService audioScrobblerService) {
        this.audioScrobblerService = audioScrobblerService;
    }

    public void setStatusService(StatusService statusService) {
        this.statusService = statusService;
    }

    public void setMusicInfoService(MusicInfoService musicInfoService) {
        this.musicInfoService = musicInfoService;
    }

    public void setSettingsService(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

    public void setSecurityService(SecurityService securityService) {
        this.securityService = securityService;
    }
}
