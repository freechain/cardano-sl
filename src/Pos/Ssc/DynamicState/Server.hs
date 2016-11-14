{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Pos.Ssc.DynamicState.Server
       (
         announceCommitment
       , announceCommitments
       , announceOpening
       , announceOpenings
       , announceShares
       , announceSharesMulti
       , announceVssCertificate
       , announceVssCertificates
       ) where

import           Control.TimeWarp.Logging      (logDebug)
import           Data.List.NonEmpty            (NonEmpty)
import           Formatting                    (sformat, (%))
import           Pos.Communication.Methods     (announceSsc)
import           Pos.Crypto                    (PublicKey, Share)
import           Pos.DHT                       (sendToNeighbors)
import           Pos.Ssc.DynamicState.Base     (Opening, SignedCommitment, VssCertificate)
import           Pos.Ssc.DynamicState.Instance (SscDynamicState)
import           Pos.Ssc.DynamicState.Types    (DSMessage (..))
import           Pos.WorkMode                  (WorkMode)
import           Serokell.Util.Text            (listJson)
import           Universum


-- TODO: add statlogging for everything, see e.g. announceTxs
announceCommitment :: WorkMode SscDynamicState m => PublicKey -> SignedCommitment -> m ()
announceCommitment pk comm = announceCommitments $ pure (pk, comm)

announceCommitments
    :: WorkMode SscDynamicState m
    => NonEmpty (PublicKey, SignedCommitment) -> m ()
announceCommitments comms = do
    -- TODO: should we show actual commitments?
    logDebug $
        sformat ("Announcing commitments from: "%listJson) $ map fst comms
    announceSsc $ DSCommitments comms

announceOpening :: WorkMode SscDynamicState m => PublicKey -> Opening -> m ()
announceOpening pk open = announceOpenings $ pure (pk, open)

announceOpenings :: WorkMode SscDynamicState m => NonEmpty (PublicKey, Opening) -> m ()
announceOpenings openings = do
    -- TODO: should we show actual openings?
    logDebug $
        sformat ("Announcing openings from: "%listJson) $ map fst openings
    announceSsc $ DSOpenings openings

announceShares :: WorkMode SscDynamicState m => PublicKey -> HashMap PublicKey Share -> m ()
announceShares pk shares = announceSharesMulti $ pure (pk, shares)

announceSharesMulti
    :: WorkMode SscDynamicState m
    => NonEmpty (PublicKey, HashMap PublicKey Share) -> m ()
announceSharesMulti shares = do
    -- TODO: should we show actual shares?
    logDebug $
        sformat ("Announcing shares from: "%listJson) $ map fst shares
    announceSsc $ DSSharesMulti shares

announceVssCertificate
    :: WorkMode SscDynamicState m
    => PublicKey -> VssCertificate -> m ()
announceVssCertificate pk cert = announceVssCertificates $ pure (pk, cert)

announceVssCertificates
    :: WorkMode SscDynamicState m
    => NonEmpty (PublicKey, VssCertificate) -> m ()
announceVssCertificates certs = do
    -- TODO: should we show actual certificates?
    logDebug $ sformat
        ("Announcing VSS certificates from: "%listJson) $ map fst certs
    void . sendToNeighbors $ DSVssCertificates certs
